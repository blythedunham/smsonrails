require 'active_record/fixtures'

unless defined?(SmsOnRails::PhoneCarrier)
  require 'sms_on_rails/phone_carrier'
end

fixture_class_names = {
  :sms_phone_carriers => 'SmsOnRails::PhoneCarrier',
}

fixture_path = File.dirname(__FILE__) + '/data/fixtures'

fixture_files = Dir.glob(fixture_path + '/*.yml').collect{|f| File.basename(f, '.yml')}
fixture_class_names.values.each {|klass| klass.constantize.delete_all }

Fixtures.create_fixtures(fixture_path, fixture_files, fixture_class_names)
