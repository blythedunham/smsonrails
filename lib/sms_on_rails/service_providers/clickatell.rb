require 'clickatell'

module SmsOnRails
  module ServiceProviders
    class Clickatell < Base
      self.provider_id = 1

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
        raise sms_error_class{ cae.code != "105" }.new("Clickatell Error:#{cae.message}")
      end
    end
  end
end

SmsOnRails::ServiceProviders::Clickatell.config ||= {:url => 'http://clickatell.com'}
