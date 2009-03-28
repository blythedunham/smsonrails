module SmsOnRails
  module ActsAsDeliverable

    def self.extended(base)#:nodoc:
      base.send :class_inheritable_hash, :acts_as_deliverable_options
      base.acts_as_deliverable_options = {
        :retry_count => 3,
        :max_messages => 30,
        :fatal_exception => nil,
        :locrec_options => {}
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
      def deliver(options={})
        deliver!
      rescue Exception => exc
         fatal_exception = acts_as_deliverable_options.merge(options)[:fatal_exception]
         raise exc if fatal_exception && exc.is_a?(fatal_exception)
         false
      end

      # Deliver and mark the status fields approriately
      def deliver!
        lock_record_and_execute { deliver_message }
      end

      # Deliver message should be overridden by the class to perform any
      # functionality
      def deliver_message
        raise(acts_as_deliverable_options[:fatal_exception]||Exception).new "Overwrite deliver_message in base class to perform the actual delivery"
      end
    end
  end
end

ActiveRecord::Base.extend SmsOnRails::ActsAsDeliverable unless defined?(ActiveRecord::Base.acts_as_deliverable_options)

