module SmsOnRails
  module ActsAsDeliverable

    def self.extended(base)#:nodoc:
      base.send :class_inheritable_hash, :acts_as_deliverable_options
      base.acts_as_deliverable_options = {
        :retry_count => 3,
        :max_messages => 30,
        :fatal_exception => nil,
        :locrec_options => {},
        :error => "Unable to deliver.",
        :already_processed_error => 'Already delivered'
      }
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_deliverable(options={})
        class_eval do
          acts_as_deliverable_options.update(options) if options
          include SmsOnRails::ActsAsDeliverable::InstanceMethods
          extend  SmsOnRails::ActsAsDeliverable::SingletonMethods
          lockable_record acts_as_deliverable_options[:locrec_options]
        end
      end
    end

    module SingletonMethods
      # Deliver a list of deliverables
      # === Parameters
      # * +deliverables+ - a deliverable or an array of deliverables
      # * +options+ - delivery options. Refer to individual delivery options
      #
      # All messages(including failed status) are delivered unless a fatal exception occurs
      # Specify <tt> :fatal_exception => nil </tt> to override this behavior
      def deliver(deliverables, options={})
        [deliverables].flatten.each do |deliverable|
          deliverable.deliver(options)
        end
      end
    end

    module InstanceMethods

      # Return true if delivery was successful
      # If unsuccessful, only raise fatal exceptions, and return false otherwise
      # === Options
      # +fatal_exception+ - specify the fatal exception Class to throw. To dismiss all exceptions, set to nil.
      # Defaults to acts_as_deliverable_options specified
      # +error+ - add an error to the objects base if delivery failed
      def deliver(options={})
        deliver!(options)
      rescue Exception => exc
        log_delivery_error(exc)
        fatal_exception = acts_as_deliverable_options.merge(options)[:fatal_exception]
        raise exc if fatal_exception && exc.is_a?(fatal_exception)
        self.errors.add_to_base(delivery_error_message(exc, options))
        false
      end

      # Deliver and mark the status fields approriately
      def deliver!(options={})
        lock_record_and_execute { deliver_message(options) }
      end

      def delivered?; already_processed?; end

      # Deliver message should be overridden by the class to perform any
      # functionality
      def deliver_message(options={})
        raise(acts_as_deliverable_options[:fatal_exception]||Exception).new "Overwrite deliver_message in base class to perform the actual delivery"
      end

      protected
      def delivery_error_message(exc, options)
        err_msg = if exc.is_a?(SmsOnRails::LockableRecord::AlreadyProcessed)
          options[:already_processed_error]|| acts_as_deliverable_options[:already_processed_error]
        end || (options[:error]||acts_as_deliverable_options[:error])
        err_msg
      end

      # Override this function to outbound errors
      # differently to a log or with a different message
      def log_delivery_error(exc)
        logger.error "Delivery Error: #{exc}"
      end
    end
  end
end

ActiveRecord::Base.extend SmsOnRails::ActsAsDeliverable unless defined?(ActiveRecord::Base.acts_as_deliverable_options)

