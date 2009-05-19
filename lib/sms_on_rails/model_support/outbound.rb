module SmsOnRails
  module ModelSupport
    module Outbound

      mattr_accessor :default_options
      self.default_options = {}
      
      def self.included(base)

        base.has_a_sms_service_provider

        base.acts_as_deliverable :fatal_exception => SmsOnRails::FatalSmsError,
                                 :error => 'Unable to send message.'


        base.acts_as_substitutable :draft_message,
                            :phone_number_digits  => :phone_number_digits,
                            :phone_number  => Proc.new{|record| record.phone_number.human_display },
                            :sender_name   => :sender_name

        base.send :alias_method, :full_message,      :substituted_draft_message
        base.send :alias_method, :send_immediately,  :deliver
        base.send :alias_method, :send_immediately!, :deliver!

        base.send :cattr_accessor, :default_options

        base.send :accepts_nested_attributes_for, :phone_number
        
        base.send :include, InstanceMethods
        base.send :extend,  ClassMethods
      end

      module ClassMethods
        def send_immediately(message, phone_number, options={})
          create_sms(message, phone_number, options.merge(:send_immediately => true))
        end

        def send_immediately!(message, phone_number, options={})
          create_sms!(message, phone_number, options.merge(:send_immediately => true))
        end

        def create_sms(message, number, options={})
          draft = reflections[:draft].klass.create_sms(message, number, options.reverse_merge(:keep_failed_outbounds => true))
          number.is_a?(Array) ? draft.outbounds : draft.outbounds.first
        end

        def create_sms!(message, number, options={})
          draft = reflections[:draft].klass.create_sms!(message, number, options)
          number.is_a?(Array) ? draft.outbounds : draft.outbounds.first
        end

        def create_outbounds_for_phone_numbers(phone_numbers, options={})
          smses = reflections[:phone_number].klass.find_and_create_all_by_numbers(phone_numbers, (options[:find]||{}).reverse_merge(:create => :new)).inject([]) do |smses, phone|
            phone.attributes = options[:phone_number] if options[:phone_number]
            phone.carrier = options[:carrier] if options[:carrier]
            sms = self.new(options[:sms]||{})
            sms.phone_number = phone
            sms.service_provider = options[:service_provider] if options[:service_provider]
            smses << sms
            smses
          end
          smses
        end

        #Create the object find the existing phone if already stored
        def create_with_phone(attributes, draft=nil)
          outbound = new(attributes)
          transaction {
            outbound.assign_existing_phone
            outbound.draft = draft
            outbound.save
          }
          outbound
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
          self.phone_number = SmsOnRails::PhoneNumber.find_and_create_by_number(phone)
        end

        def assign_existing_phone; assign_phone_number(self.phone_number); end

        # The actual (not substituted draft message
        # Substituted message can be obtained with +substituted_draft_message+
        def draft_message; draft.complete_message if draft; end

        def actual_message
          read_attribute(:actual_message) || draft_message
        end
        
        #only save the actual message if it differs from the draft message
        def actual_message=(msg)
          write_attribute(:actual_message, msg) unless substituted_draft_message == draft_message
        end
        
        #Todo
        def sender_name; ''; end

        protected

        # deliver_message is the actual call to the service provider to send the message
        # this method is called during deliver in the acts_as_deliverable
        def deliver_message(options)
          self.sms_service_provider||= default_service_provider

          # set the actual message if it differs; not a before_save to reduce the
          # overhead of checking for all commits
          self.actual_message = substituted_draft_message

          result = (self.sms_service_provider).send_sms(self)
          self.unique_id = result[:unique_id] if result.is_a?(Hash)
       
          result
        end

        def log_delivery_error(exc)
          logger.error "SMS Delivery Error: #{self.phone_number.human_display if self.phone_number}: #{exc}"
        end
      end
    end
  end
end
