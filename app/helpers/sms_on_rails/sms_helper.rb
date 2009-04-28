# To change this template, choose Tools | Templates
# and open the template in the editor.

module SmsOnRails::SmsHelper
  def link_to_sms_phone_number(phone_number)
    return '' unless phone_number
    link_to phone_number.human_display, sms_phone_number_url(:id => phone_number)
  end

  def link_to_sms_draft(draft)
    return '' unless draft
    link_to draft.message, sms_draft_url(:id => draft)
  end

  def service_providers_collection_select(form)
    @@spc_select||= form.select(:sms_service_provider_id,
      SmsOnRails::ServiceProviders::Base.provider_list.collect{|x|  [ x.human_name, x.provider_id ]},
      :include_blank => true)
  end

  def sms_on_rails_status_select(form, options={})
    form.select(:status, form.object.class.locrec_status.values.collect{|x| [x.titleize, x]},
      options)
  end

end
