require File.dirname(__FILE__)+'/../test_helper'

#require 'ruby-debug'

class SmsOnRails::OutboundTest  < Test::Unit::TestCase

  def test_outbound_create_sms_simple
    SmsOnRails::Outbound.delete_all
    sms = SmsOnRails::Outbound.create_sms 'hi', '2065552476'
    assert(sms)
    assert(sms.is_a?(ActiveRecord::Base))

    validate_new_sms('12065552476', 'hi')
  end


  def test_outbound_create_sms_multiple
    SmsOnRails::Outbound.delete_all
    smses = SmsOnRails::Outbound.create_sms 'multi test', ['2065552476', '206.555.1234', '1(415)5551234']
    assert(smses)
    assert_equal(3, smses.length)

    ['12065552476', '12065551234', '14155551234'].each do |number|
      validate_new_sms(number, 'multi test')
    end
  end

  def test_outbound_send_immediately
    SmsOnRails::Outbound.delete_all
    sms = SmsOnRails::Outbound.send_immediately 'hi', '2065552476'

    sms = SmsOnRails::Outbound.find :first
    assert(sms)
    assert_equal('PROCESSED', sms.status)
    assert(sms.processed_on.to_i <= Time.now.to_i)
  end

  def test_outbound_send_immediately_for_multiple
    SmsOnRails::Outbound.delete_all
    smses = SmsOnRails::Outbound.send_immediately 'hi', ['2065552476', '4155553456']

    smses = SmsOnRails::Outbound.find :all
    assert(smses.length, 2)
    smses.each{|sms| assert('PROCESSED', sms.status)
      assert(sms.processed_on.to_i <= Time.now.to_i)
      assert_equal(SmsOnRails::ServiceProviders::Base.default_service_provider, 
        sms.sms_service_provider)
      }
  end


  def test_outbound_substitution
    SmsOnRails::Outbound.delete_all
    time = Time.now
    sms = SmsOnRails::Outbound.create_sms '$TIME$', '2065552476'
    time_sub = Time.parse sms.full_message
    assert(time_sub.to_i >= time.to_i)

    sms = SmsOnRails::Outbound.create_sms 'Format phone: $PHONE_NUMBER_DIGITS$ end', '2065552476'
    assert_equal('Format phone: 12065552476 end', sms.full_message)

    sms = SmsOnRails::Outbound.create_sms 'Format phone human: $PHONE_NUMBER$ end', '2065552476'
    assert_equal('Format phone human: (206) 555-2476 end', sms.full_message)
    
  end
  
  def test_send_to_invalid_number
    assert_raise(ActiveRecord::RecordInvalid){
      sms = SmsOnRails::Outbound.create_sms 'some test message #{Time.now.to_s(:db)}', 'ss', :find => {:create => :create!}
    }
  end

  protected

  def validate_new_sms(phone_number, message)
    phone = SmsOnRails::PhoneNumber.find_by_number phone_number
    assert(phone)

    outbound = SmsOnRails::Outbound.find_by_sms_phone_number_id phone
    assert(outbound)
    assert(outbound.draft)
    assert(SmsOnRails::ServiceProviders::Dummy.provider_id, outbound.sms_service_provider_id)
    assert_nil(outbound.sms_service_provider)
    assert_equal(message, outbound.draft.message)
    assert_equal('NOT_PROCESSED', outbound.status)
    outbound
  end
end

