module SmsOnRails
  module ModelSupport
    module PhoneNumber
      def self.included(base)
        base.send :include,InstanceMethods
        base.send :extend, ClassMethods
        base.send :validates_format_of, :phone_number_digits, :with => /^\d{5,30}$/, :message => 'must be number and have at least 5 digits'
        base.before_save {|record| record.number = record.digits}
        base.send :validates_presence_of, :number

      end
    end

    module ClassMethods
      def find_all_by_numbers(numbers, options={})

        creation_method = :create! if options.delete(:create!)
        creation_method = :create if options.delete(:create)

        numbers = [numbers].flatten
        return numbers if numbers.first.is_a?(ActiveRecord::Base)

        found_numbers = find(:all, :conditions => ['number in (?)', numbers.collect!{|n| digits(n) }.uniq.compact])
        if creation_method
          new_numbers = (numbers - found_numbers.collect(&:digits))
          new_numbers.collect! { |n| send(creation_method, :number => n) }
          found_numbers.concat(new_numbers)
        end
        found_numbers
      end

      def find_by_phone_number(number, options={})
        phone = find_all_by_numbers(number, options).first
        phone
      end

      # Return the phone number with specified carrier if the phone number is an sms email address
      def find_by_sms_email_address(address, options={})
        number, carrier = SmsOnRails::PhoneCarrier.carrier_from_sms_email(address)
        if number && carrier
          phone = find_by_phone_number(number, options)
          phone.carrier = carrier
        end
        phone
      end

      # The digits (numbers) only of the phone number
      # Digits are how phone numbers are stored in the database
      # The following all return +12065555555+
      #  SmsOnRails::digits(12065555555')
      #  SmsOnRails::digits(206.555.5555')
      #  SmsOnRails::digits(1206-555  5555')
      def digits(text)
        number = text.to_s.gsub(/\D/,'')
        number = "1#{number}" if number.length == 10
        number
      end

      # The human display pretty phone number
      # (206) 555-5555
      def human_display(number)
        base_number = digits(number)
        if base_number.length == 11 && base_number.first == '1'
          "(#{base_number[1..3]}) #{base_number[4..6]}-#{base_number[7..10]}"
        else
          "+#{base_number}"
        end
      end
    end

    module InstanceMethods
      # The human display pretty phone number
      # (206) 555-5555
      def human_display
        self.class.human_display(self.number)
      end

      def number=(value)
        @digits = self.class.digits(value)
        write_attribute :number, @digits
      end

      def digits
        @digits||=self.class.digits(self.number)
      end

      def sms_email_address
        carrier.sms_email_address(self) if carrier
      end
      
      alias_method  :phone_number_digits, :digits

      # Returns true if the number is marked as do not send (not blank)
      # Values could be abuse, bounce, opt-out, etc
      def do_not_send?
        !self.do_not_send.blank?
      end
      
    end
  end
end
