require File.dirname(__FILE__)+'/../test_helper'

module SmsOnRails::ServiceProviders::AbstractTestSupport
  mattr_accessor :test_phone_number
  self.test_phone_number ||= '12065552476'

  def test_ping
    assert provider_klass.instance.ping
  end

  def test_send_sms
    sms = SmsOnRails::Outbound.create_sms "some test message #{Time.now.to_s(:db)}", test_phone_number, default_options
    result = provider_klass.instance.send_sms sms
    assert test_phone_number, sms.phone_number.number
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

    phone.update_attribute(:white_list, true)
    sms = SmsOnRails::Outbound.create_sms "some test message #{Time.now.to_s(:db)}", test_phone_number, default_options
    assert(!sms.new_record?)
    
  ensure
    provider_klass.config = original_config
    provider_klass.config[:white_list] = false
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

  def test_send_message
    map = provider_instance.send_message(send_to_phone_data, "SEND MESSAGE #{send_to_phone_data}")
    assert(map.is_a?(Hash))
  end

  def test_send_to_phone_number_with_white_list
    original_config = provider_klass.config.dup
    provider_klass.config[:white_list] = true
    SmsOnRails::PhoneNumber.delete_all
    phone = SmsOnRails::PhoneNumber.create!(:number => '206555555  5', :carrier_id => 5)

    assert_raises(SmsOnRails::SmsError) { 
      provider_instance.send_to_phone('1206.555.5555', 'test send to phone', :carrier => 5)
    }

    phone.update_attribute(:white_list, true)
    provider_instance.send_to_phone('1206.555.5555', 'test send to phone', :carrier => 5)
  ensure
    provider_klass.config = original_config
    provider_klass.config[:white_list] = false
  end


  def test_send_to_phone
    SmsOnRails::PhoneNumber.delete_all
    response = provider_instance.send_to_phone('1206.555.5555', 'test send to phone', :carrier => 5)
  end

  def test_send_to_phone_with_existing_number
    SmsOnRails::PhoneNumber.delete_all
    SmsOnRails::PhoneNumber.create!(:number => '12065555555', :carrier_id => 5, :white_list => true)
    response = provider_instance.send_to_phone('206.555.5555', 'test send to phone', :carrier => 4)
  end

  protected

  def send_to_phone_data; '12065551234'; end
  def default_options; {}; end

  def provider_klass
    @provider_klass||= self.class.to_s.gsub(/Test$/,'').constantize
  end

  def provider_instance; provider_klass.instance; end
end
