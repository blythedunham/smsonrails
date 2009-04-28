module SmsOnRails::PhoneNumbersHelper
  def phone_carriers_collection_select(form)
    form.collection_select('carrier_id',SmsOnRails::PhoneCarrier.find(:all), :id, :name)
  end
end
