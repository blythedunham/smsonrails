module SmsOnRails::PhoneNumbersHelper
  def phone_carriers_collection_select(form)
    form.collection_select('carrier_id',SmsOnRails::PhoneCarrier.find(:all), :id, :name)
  end
  
  def phone_number_carrier_link(phone_number)
    link_to(phone_number.carrier.name, sms_phone_carrier_path(phone_number.carrier_id)) if phone_number.carrier
  end
end
