module SmsOnRails
  class PhoneNumber < ActiveRecord::Base
    set_table_name 'sms_phone_numbers'
    has_many   :outbounds, :class_name => 'SmsOnRails::Outbound',
               :foreign_key => 'sms_phone_number_id', :dependent => :delete_all
    has_many   :inbounds, :class_name => 'SmsOnRails::Inbound',
               :foreign_key => 'sms_phone_number_id', :dependent => :delete_all
    belongs_to :carrier, :class_name => 'SmsOnRails::PhoneCarrier',
               :foreign_key => :carrier_id

    include SmsOnRails::ModelSupport::PhoneNumber
    
  end
end