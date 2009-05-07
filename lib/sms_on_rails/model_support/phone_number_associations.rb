module SmsOnRails
  module ModelSupport
    module PhoneNumberAssociations
      def self.included(base)
        base.send :has_many,   :outbounds, :class_name => 'SmsOnRails::Outbound',
               :foreign_key => 'sms_phone_number_id', :dependent => :delete_all
        base.send :belongs_to, :carrier, :class_name => 'SmsOnRails::PhoneCarrier',
               :foreign_key => :carrier_id
      end
    end
  end
end

