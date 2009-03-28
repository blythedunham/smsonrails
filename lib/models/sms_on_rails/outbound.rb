module SmsOnRails
  class Outbound < ActiveRecord::Base
    set_table_name 'sms_outbounds'
    belongs_to :draft, :class_name => 'SmsOnRails::Draft', :foreign_key => :sms_draft_id
    belongs_to :phone_number, :class_name => 'SmsOnRails::PhoneNumber', :foreign_key => :sms_phone_number_id

    include SmsOnRails::ModelSupport::Outbound
  end
end
