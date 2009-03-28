module SmsOnRails
  module ServiceProviders
    class Base 
      include Singleton

      #the configuration options for the service provider
      class_inheritable_hash :config
      self.config ||= {}

      #special deliver options specific to the service provider
      class_inheritable_accessor  :delivery_options
      self.delivery_options ||= {}

      #the default service provider
      cattr_accessor :default_service_provider

      #a unique id by which each service provider is identified
      class_inheritable_accessor :provider_id, :instance_writer => false

      #the logger -> ActiveRecord::Base.logger
      cattr_accessor :logger
      @@logger ||= ActiveRecord::Base.logger

      def deliver
        Outbound.deliver(delivery_options.merge(:conditions => ['sms_service_provider_id = ?', self.provider_id]))
      end

      [:config, :name, :provider_id, :logger, :human_name].each{|method| class_eval  "def #{method}; self.class.#{method}; end"}


      # Sends a message to a phone number directly to the provider.
      # No validations are performed
      # * +phone_number+ the exact string text to send
      # * +message+ - the string message to send
      # * +options+ - additional options to be used by the provider
      #
      def send_message(phone_number, message, options={})
        raise SmsOnRails::SmsError.new("Override send_message in subclass #{self.class}")
      end


      
      # Sends a message to a phone number active record object or string
      # and performs validation on the phone_number
      #
      # * +phone_number+ can be either a phone number active record obj or a string text. Strings are converted to phone_number objects
      # * +message+ - the message to send
      # * +options+ - additional options to be used by the provider
      #
      # ===Options
      # <tt>:skip_validation</tt> - skips validation and sends the message directly to the
      # provider
      def send_to_phone(phone_obj, message, options={})

        if options[:skip_validation]
          phone_text = phone_obj.is_a?(ActiveRecord::Base) ? format_phone_number(phone_number) : phone_obj
          return send_message(phone_obj, message, options)
        end

        phone_number = phone_obj.is_a?(ActiveRecord::Base) ? phone_obj :
                       find_or_create_phone_number(phone_number)

        assert_message_options!(phone_number, message, options)
        send_message(format_phone_number(phone_number), message, options)
      end

      # Send an Sms with validation
      # +sms+ is an sms active record object that responds to phone_number and full_message
      #
      # Refer to send_to_phone for more infomation on validation
      def send_sms(sms, options={})
        send_to_phone(sms.phone_number, sms.full_message, options)
      end

      protected

      #can override in subclass if different finder should be used
      def find_or_create_phone_number(phone_text, options={})
        phone_klass.find_by_number(phone_text, options.reverse_merge(:create => true))
      end

      #override this if the expected format differs in subclass
      def format_phone_number(phone_number)
        phone_number.digits
      end

      # Raise an exception if the white list is being used (only sends to people on this list)
      # and this phone number is not on the list
      def check_white_list!(phone_number)
        if self.class.config[:white_list] && !phone_number.white_list?
          raise SmsOnRails::SmsError.new("Phone number #{phone_number} is not in white list")
        end
      end

      # Raise an exception if this phone_number is marked as do not send
      def check_do_not_send!(phone_number)
        if phone_number.do_not_send?
          raise SmsOnRails::SmsError.new("Phone number #{phone_number} do not send is set:#{phone_number.do_not_send}")
        end
      end

      # Raise exception if invalid data is entered
      def assert_message_options!(phone_number, message, options)
        raise SmsOnRails::SmsError.new("Invalid or undefined phone number: #{phone_number}") unless phone_number && phone_number.valid?
        raise SmsOnRails::SmsError.new("No message specified") unless message
        raise SmsOnRails::SmsError.new("Message is too long. #{message}") if message.length > self.class.max_characters
        check_white_list!(phone_number)
        check_do_not_send!(phone_number)
      end

      # return the appropriate exception class
      # Return a fatal error if the block returns true and a non fatal if the
      # block returns false
      def sms_error_class(&block)#:nodoc
        if yield
          SmsOnRails::FatalSmsError
        else
          SmsOnRails::SmsError
        end
      end

      # The class used for phone numbers
      # can be overwritten and specified in environment.rb
      def phone_klass
        config[:phone_klass]||SmsOnRails::PhoneNumber
      end

      class << self

         def max_characters
           self.config[:max_characters]||140
         end

         # Name of service provider (downcase no spaces)
         def name
           @name ||= self.to_s.demodulize.downcase
         end

         # Human name of provider
         def human_name
           @human_name ||= self.to_s.demodulize.titleize
         end

         # Hash map of provider_id to the provider
         def provider_map
           @provider_map ||= provider_list.inject({}) do |map, klass|
             map[klass.provider_id] = klass unless klass.nil?
             map
           end
         end

         #List of all providers available
         def provider_list
           @provider_list ||= subclasses.inject([]) do |list, klass_name|
             klass = klass_name.constantize
             list << klass.instance
             list
           end
         end

         # Locate the service provider by provider id
         #  Example: SmsOnRails::ServiceProviders::Base.provider_by_id 1
         def provider_by_id(provider_id)
           provider_map[provider_id.to_i] if provider_id.to_i > 0
         end

         # Locate the service provider by name or symbol
         #  Example: SmsOnRails::ServiceProviders::Base.provider_by_name :dummy
         def provider_by_name(provider_name)
           key = provider_name.to_s.downcase
           provider_list.detect{|p| key == p.name || provider_name == p.human_name}
         end

         # Locate the service provider object by provider_id, string, symbol, or ServiceProvider object
         # Defaults to the default service provider
         #   SmsOnRails::ServiceProviders::Base.get_service_provider :dummy
         #   SmsOnRails::ServiceProviders::Base.get_service_provider 1
         #   SmsOnRails::ServiceProviders::Base.get_service_provider SmsOnRails::ServiceProviders::Dummy
         def get_service_provider(provider)
           case provider.class.to_s
            when 'Fixnum'           then provider_by_id(provider)
            when 'String'           then (value.to_i > 0 ? provider_by_id(provider) : provider_by_name(provider))
            when 'Symbol'           then provider_by_name(provider)
            when 'NilClass'         then nil
            else
              provider
            end
         end
      end
    end
  end
end