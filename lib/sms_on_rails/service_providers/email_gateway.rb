#Require all the email gateway support files
Dir.glob(File.dirname(__FILE__) + '/email_gateway_support/*.rb').each {|f| require f }

module SmsOnRails
  module ServiceProviders
    class EmailGateway < Base
        self.provider_id = 3

        def ping; true; end

        def mailer_klass; self.class.mailer_klass; end

        def requires_carrier?; true; end
        
        protected



        # Email Gateway Send message
        #
        #   send_message('2065551234@txt.att.net', 'My message')
        #   send_message('12065551234', 'my message', :carrier => 'Verizon')
        #   send_message(['12065551234', '4125556667'], 'my message', :carrier => 'Verizon')
        #
        # === Params
        # * +phone_number+ - can be one of the following
        #    sms_email_address. Example: '2065551234@txt.att.net'
        #    phone number string with or without the country code: example: '12065556666'
        #    array of sms_email_addresses
        #    array of phone number strings
        # * +message+ - the text message to send
        # 
        # ===Options
        # * <tt>:carrier</tt> - can be symbol, name, id, or SmsOnRails::PhoneCarrier object
        # * <tt>:sender</tt>  - email address of the sender overrides default
        # * <tt>:bcc</tt>     - email_address or array of email_addresses to blind carbon copy

        def send_message(phone_text, message, options={})
          mailer_klass.deliver_sms_through_gateway(phone_text, message, self.class.config.merge(options))
          {}
        end

        #the formate for email is the sms email address
        def format_phone_number(phone_number)
          phone_number.sms_email_address
        end

        # additional check to make sure the sms_email_address is valid
        def assert_message_options!(phone_number, message, options)
          super(phone_number, message, options)
          unless phone_number.carrier || phone_number.sms_email_address
            raise EmailGatewayInvalidSms.phone_error(phone_number)
          end
        end

        # override to append the carrier if specified as part of the phone number
        # or as a separate option
        def find_or_create_phone_number(phone_text, options={})
          phone = phone_klass.find_by_sms_email_address(phone_text)
          phone ||= super(phone_text, options)

          if options[:carrier]
            phone.carrier = carrier_klass.carrier_by_value(options[:carrier])
          end
        end

        class << self
          # The mailer class to use that can be specified in the config options for :mailer_klass
          def mailer_klass#:nodoc:
            @mailer_klass ||= config[:mailer_klass]||SmsOnRails::ServiceProviders::EmailGatewaySupport::SmsMailer
          end
        end
      end

  end
end
