require File.dirname(__FILE__)+'/../test_helper'

module SmsOnRails::ServiceProviders::AbstractTestSupport
  mattr_accessor :test_phone_number
  self.test_phone_number ||= '12063512476'


  def test_ping
    assert provider_klass.instance.ping
  end

  def test_send_sms
    sms = SmsOnRails::Outbound.create_sms "some test message #{Time.now.to_s(:db)}", test_phone_number, default_options
    result = provider_klass.instance.send_sms sms
    assert(result.is_a?(Hash))
  end

  def test_send_sms_off_white_list
    original_config = provider_klass.config.dup
    provider_klass.config[:white_list] = true

    phone = SmsOnRails::PhoneNumber.find_and_create_by_number test_phone_number, :create => :create
    
    phone.white_list = false
    phone.save!
    
   assert_raise(SmsOnRails::SmsError){
     sms = SmsOnRails::Outbound.create_sms "some test message #{Time.now.to_s(:db)}", test_phone_number, default_options
     result = provider_klass.instance.send_sms sms
     assert(result.is_a?(Hash))
   }
  ensure
    provider_klass.config = original_config
    phone.destroy
  end


  def test_do_not_send_errors_out

    phone = SmsOnRails::PhoneNumber.find_and_create_by_number test_phone_number, :create => true
    phone.do_not_send = 'bounce'
    phone.save!

    assert_raise(SmsOnRails::SmsError){
      sms = SmsOnRails::Outbound.create_sms "some test message #{Time.now.to_s(:db)}", test_phone_number, default_options
      result = provider_klass.instance.send_sms sms
      assert(result.is_a?(Hash))
    }

  ensure
    phone.destroy
  end

  protected
  
  def default_options; {}; end

  def provider_klass
    @provider_klass||= self.class.to_s.gsub(/Test$/,'').constantize
  end
end
