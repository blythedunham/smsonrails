module SmsOnRails
  module ModelSupport
    module Outbound

      mattr_accessor :default_options
      self.default_options = {}
      
      def self.included(base)

        base.has_a_sms_service_provider

        base.acts_as_deliverable :fatal_exception => SmsOnRails::FatalSmsError


        base.acts_as_substitutable :draft_message,
                            :phone_number_digits  => :phone_number_digits,
                            :phone_number  => Proc.new{|record| record.phone_number.human_display },
                            :sender_name   => :sender_name

        base.send :alias_method, :full_message, :substituted_draft_message

        base.send :cattr_accessor, :default_options

        base.send :accepts_nested_attributes_for, :phone_number

        base.send :include, InstanceMethods
        base.send :extend,  ClassMethods
      end

      module ClassMethods
        def send_immediately(message, phone_number, options={})
          create_sms(message, phone_number, options.merge(:send_immediately => true))
        end

        def create_sms(message, number, options={})
          draft = message.is_a?(String) ?
            reflections[:draft].klass.new((options[:draft]||{}).merge(:message => message)) :
            message

          draft.save! if draft.new_record?

          smses = reflections[:phone_number].klass.find_all_by_numbers(number, :create => true).inject([]) do |smses, phone|
            phone.update_attributes(options[:phone_number]) if options[:phone_number]
            sms = self.new(options[:sms]||{})
            sms.phone_number = phone
            sms.draft = draft
            sms.service_provider = options[:service_provider] if options[:service_provider]
            smses << sms
            sms.save!
            sms.deliver! if options[:send_immediately]
            smses
          end

          number.is_a?(Array) ? smses : smses.first
        end
      end #ClassMethods

      module InstanceMethods

        def phone_number_digits
          self['phone_number_digits']||(phone_number ? phone_number.number : nil)
        end

        def phone_number_digits=(digits)
          self.phone_number ||= SmsOnRails::PhoneNumber.new
          self.phone_number.number = digits
          assign_existing_phone
          self.phone_number.number
        end

        def assign_phone_number(phone)
          self.phone_number = SmsOnRails::PhoneNumber.find_or_create_by_phone_number(phone)
        end

        def assign_existing_phone; assign_phone_number(self.phone_number); end

        def draft_message; draft.complete_message; end


        #Todo
        def sender_name; 'Blah'; end

        protected

        # deliver_message is the actual call to the service provider to send the message
        # this method is called during deliver in the acts_as_deliverable
        def deliver_message(options)
          self.sms_service_provider||= default_service_provider
          result = (self.sms_service_provider).send_sms(self)
          self.unique_id = result[:unique_id] if result.is_a?(Hash)
          result
        end
      end
    end
  end
end
