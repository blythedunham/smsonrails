module SmsOnRails
  class PhoneCarrier < ActiveRecord::Base

    set_table_name 'sms_phone_carriers'

    acts_as_static_record :key => :name
    
    has_many :phone_numbers, :class_name => 'SmsOnRails::PhoneNumber',
             :foreign_key => 'carrier_id', :dependent => :nullify

    include SmsOnRails::ModelSupport::PhoneCarrier

  end
end
