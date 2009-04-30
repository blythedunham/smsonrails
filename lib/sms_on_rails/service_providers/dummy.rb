module SmsOnRails
  module ServiceProviders
    class Dummy < Base

      self.provider_id = 2

      def ping
        true
      end

      def send_message(phone_number, message, options={})
        response = {:unique_id => "#{$$}:#{Time.now.strftime('%Y%m%d%H%M%SZ')}.#{rand(1000)}"}
        response
      end
      
    end
  end
end
SmsOnRails::ServiceProviders::Base.default_service_provider ||= SmsOnRails::ServiceProviders::Dummy.instance