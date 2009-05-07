module SmsOnRails
  class Outbound < ActiveRecord::Base
    set_table_name 'sms_outbounds'
    belongs_to :draft, :class_name => 'SmsOnRails::Draft', :foreign_key => :sms_draft_id
    belongs_to :phone_number, :class_name => 'SmsOnRails::PhoneNumber', :foreign_key => :sms_phone_number_id

    #adding this here instead of support since might not want it
    #for performance reasons
    validates_uniqueness_of :sms_phone_number_id, :scope => :sms_draft_id, :message => 'is already included as an outbound for this draft'
    
    include SmsOnRails::ModelSupport::Outbound

  end
end
