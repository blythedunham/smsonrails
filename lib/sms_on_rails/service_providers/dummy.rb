module SmsOnRails
  module ServiceProviders
    class Dummy < Base

      self.provider_id = 2

      def ping
        logger.debug "SMS DUMMY: ping()"
        true
      end

      def send_message(phone_number, message, options={})
        response = {:unique_id => "#{$$}:#{Time.now.strftime('%Y%m%d%H%M%SZ')}.#{rand(1000)}"}
        logger.debug "SMS DUMMY: send_message(#{phone_number.inspect}, #{message.inspect}, #{options.inspect})\n RESPONSE:#{response.inspect}"
        response
      end
      
    end
  end
end
SmsOnRails::ServiceProviders::Base.default_service_provider ||= SmsOnRails::ServiceProviders::Dummy.instance