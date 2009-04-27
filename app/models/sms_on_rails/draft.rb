module SmsOnRails
  class Draft < ActiveRecord::Base
    set_table_name 'sms_drafts'
    has_many :inbounds,  :class_name => 'SmsOnRails::Inbound',  :foreign_key => :sms_draft_id, :dependent => :nullify
    has_many :outbounds, :class_name => 'SmsOnRails::Outbound', :foreign_key => :sms_draft_id, :dependent => :nullify

    include SmsOnRails::ModelSupport::Draft
    
  end
end

