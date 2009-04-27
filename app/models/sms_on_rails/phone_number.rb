module SmsOnRails
  class PhoneNumber < ActiveRecord::Base
    set_table_name 'phone_numbers'

    include SmsOnRails::ModelSupport::PhoneNumberAssociations
    include SmsOnRails::ModelSupport::PhoneNumber
  end#end PhoneNumber
end
