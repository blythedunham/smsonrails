module SmsOnRails
  module ServiceProviders
    class EmailGatewayInvalidSms < SmsOnRails::SmsError
      def self.phone_error(phone_number)
        new(self.phone_message(phone_number))
      end
      def self.phone_message(phone_number)
        msg =  "Invalid phone number #{phone_number.human_display if phone_number}. "
        msg << "Please specify the digits and the option :carrier, "
        msg << "or specify the full email address like 2065551234@txt.att.net"
      end
    end

    class EmailGatewayInvalidCarrier < EmailGatewayInvalidSms
      def self.phone_message(phone_number)
        msg =  "The carrier for #{phone_number.human_display if phone_number} is invalid."
      end
    end
  end
end