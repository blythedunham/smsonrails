module SmsOnRails
  class Inbound < ActiveRecord::Base
    set_table_name "sms_inbounds"
    
    belongs_to :sms_draft
    belongs_to :phone_number
    has_many   :outbounds, :through => :sms_draft

    
    has_a_sms_service_provider

  end
end