module SmsOnRails
  module ServiceProviders
    class Clickatell < Base
      self.provider_id = 1

      FATAL_ERROR_CODES = %w(105 114) unless defined?(FATAL_ERROR_CODES)
      
      def initialize
        begin
          require 'clickatell'
        rescue LoadError => exc
          raise LoadError.new(exc.to_s + " Please make sure the clickatell gem is installed.")
        end
        super
      end
      
      def ping
        result = invoke_clickatell{ api.ping(nil) }
        result.is_a?(Net::HTTPOK)
      end

      def authenticate
        invoke_clickatell{ api }
      end

      #Send a message without validation
      # * phone_number - phone number string digits
      # * message - the message text
      # * options - anything else
      def send_message(phone_number, message, options={})
        unique_id = invoke_clickatell{  api.send_message(phone_number, message) }
        {:unique_id => unique_id}
      end

      protected

      #Get the api key
      def api#:nodoc:
        @@api ||= ::Clickatell::API.authenticate(config[:api_id], config[:user_name], config[:password])
      end

      # wrap this method around all clickatell calls
      # if anything other than a 105 is thrown, reraise FatalSmsError
      def invoke_clickatell(&block)#:nodoc
        yield
        
      rescue ::Clickatell::API::Error => cae
        raise sms_error_class{ !(FATAL_ERROR_CODES.include?(cae.code)) }.new("Clickatell Error:#{cae.code}:#{cae.message}", cae.code)
      end
    end
  end
end
