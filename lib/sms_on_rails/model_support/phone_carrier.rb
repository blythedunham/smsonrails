module SmsOnRails
  module ModelSupport
    module PhoneCarrier
      def self.included(base)
        base.send :validates_presence_of, :name
        base.send :include, InstanceMethods
        base.send :extend, ClassMethods
      end

      module ClassMethods

        # Returns the email address for sms
        #
        # * +phone+ - phone number digits or an SmsOnRails::PhoneCarrier
        # * +carrier+ - the name, instance, or id of a carrier
        #
        #  SmsOnRails::PhoneCarrier.sms_email_address('12065551111', 1) => '2065551111@att.txt.net'
        def sms_email_address(phone, carrier)
          phone_carrier = carrier_by_value(carrier)
          raise SmsOnRails::SmsError("Invalid carrier: #{carrier}") unless phone_carrier
          phone_carrier.sms_email_address(phone)
        end

        # Retrurns the SmsOnRails::PhoneCarrier object
        # +carrier+ can be
        # * symbol name of the object (ex :verizon)
        # * text name (Ex. 'Verizon')
        # * SmsOnRails::PhoneCarrier instance returns self
        # * the id number
        def carrier_by_value(carrier)
          phone_carrier = case carrier.class.to_s
            when 'Symbol', 'String'   then find_by_name(carrier)
            when "#{self.class.to_s}" then carrier
            when 'Fixnum'             then find_by_id(carrier)
            else nil
          end
        end

        # Return the number text and carrier obj from an email string
        # carrier_from_sms_email '12065551234@txt.att.net ' => [12065551234, <SmsOnRails::PhoneCarrier>]
        def carrier_from_sms_email(address)

          number = address
          carrier = nil

          if address.match(/^\s*(\d+)@(\S+)\s*$/)
            number = match[1]
            carrier_name = match[2]
            carrier = find_by_email_domain(match[2]) if match[2]
          end
          
          [number, carrier]
        end
      end
      module InstanceMethods

        # Returns the email address for sms
        #
        # * +phone+ - phone number digits or an SmsOnRails::PhoneNumber
        # * +options+ - empty space now
        #
        #  att_carrier.sms_email_address('12065551111') => '2065551111@att.txt.net'
        #
        def sms_email_address(phone, options={})
          email = (phone.is_a?(ActiveRecord::Base) ? phone.digits : phone).dup
          email.gsub!(/^1/, '')
          email << '@'
          email << self.email_domain
          email
        end

        # Return the carriers name when stringified
        def to_s; name; end
      end
    end
  end
end
