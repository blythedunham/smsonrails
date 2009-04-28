module SmsOnRails
  module ModelSupport
    module Draft

      def self.included(base)#:nodoc
        base.send :accepts_nested_attributes_for, :outbounds
        #base.acts_as_deliverable :fatal_exception => SmsOnRails::FatalSmsError

        base.validates_presence_of  :message
        base.validate :validates_message_length

        base.class_inheritable_accessor  :default_header
        base.class_inheritable_accessor  :default_footer
        base.class_inheritable_accessor  :max_message_length
        
        base.max_message_length = SmsOnRails::ServiceProviders::Base.max_characters

        base.send :include, InstanceMethods
        base.send :extend,  ClassMethods
      end

      module ClassMethods

      end

      module InstanceMethods

        def initialize(args={})#:nodoc:
          super args
          default_headers_and_footers
        end


        # The length of the message
        # This does not take into consideration substituted params
        # TODO: adjust max length for substituted params
        def message_length; complete_message.length; end
        def max_message_length; self.class.max_message_length; end

        # default the headers and footers
        def default_headers_and_footers
          self.header ||= self.class.default_header
          self.footer ||= self.class.default_footer
        end

        def complete_message
          complete_message = ""
          complete_message << "#{header}\n" unless header.blank?
          complete_message << message
          complete_message << "\n#{footer}" unless footer.blank?
          complete_message
        end


        # Deliver all the unsent outbound messages
        # +error+ - set this option to add an error message to the draft object
        #
        # This is locked and safe for individual messages
        # but the draft object itself is not locked down,
        # so it can be processed by multiple threads
        def deliver(options={})
          success = outbounds.inject(true) do |delivered, o|
            next(delivered) if o.delivered?
            unless o.deliver(options)
             self.errors.add_to_base("Message could not be delivered to: #{o.phone_number.human_display}") if options[:error]
             delivered = false
            end
            delivered
          end
          self.update_attribute(:status, success ?  'PROCESSED' : 'FAILED')
          success
        end

        protected

        # validates the length of the message including the header and footer
        def validates_message_length
          errors.add(:message, "must be less than #{max_message_length} characters") unless message_length < max_message_length
        end

      end
    end
  end
end