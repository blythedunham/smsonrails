require File.dirname(__FILE__)+'/../test_helper'

#require 'ruby-debug'

class SmsOnRails::Outbound < ActiveRecord::Base
  def deliver_message_with_exception(options={})
    raise Exception.new('asdf')
  end
end

class SmsOnRails::DeliveryAndLockingTest  < Test::Unit::TestCase

  def setup
    super
    SmsOnRails::ServiceProviders::Base.default_service_provider = SmsOnRails::ServiceProviders::Dummy.instance
  end

  def test_failed_delivery_with_exception
    SmsOnRails::Outbound.send :alias_method_chain, :deliver_message, :exception
    SmsOnRails::Outbound.delete_all

    sms = nil
    assert_raises(Exception) {
      sms = SmsOnRails::Outbound.send_immediately! 'hi', '2065552476'
    }
    
    sms = SmsOnRails::Outbound.find :first
    assert(sms)

    assert_equal('FAILED', sms.status)
    #assert(sms.processed_on.to_i <= Time.now.to_i)
  ensure
    SmsOnRails::Outbound.send :alias_method, :deliver_message, :deliver_message_without_exception
  end


  def test_failed_delivery_with_errors
    SmsOnRails::Outbound.send :alias_method_chain, :deliver_message, :exception
    SmsOnRails::Outbound.delete_all

    sms = SmsOnRails::Outbound.send_immediately 'hi', '2065552476'
    assert(sms, "SHOULD create and SMS object")
    assert(sms.errors.any?, "Expecting deliver errors.")

    assert_equal(sms.errors.on(:base), 'Unable to send message.')
    sms = SmsOnRails::Outbound.find :first
    assert(sms)

    assert_equal('FAILED', sms.status)
    assert(sms.processed_on.to_i <= Time.now.to_i)
  ensure
    SmsOnRails::Outbound.send :alias_method, :deliver_message, :deliver_message_without_exception
  end

  def test_deliver_stale_record_should_raise_unlockable_error
     SmsOnRails::Outbound.delete_all

     #get the sms instance
     sms = SmsOnRails::Outbound.create_sms 'hi', '2065552476'

     #change the lock id
     same_sms = SmsOnRails::Outbound.find :first
     same_sms.notes = 'something fun'
     same_sms.save!

     #attempt to deliver should catch stale record and raise unable to lock
     assert_raises(SmsOnRails::LockableRecord::UnableToLockRecord) { sms.deliver! }
  end

  def test_deliver_already_processed_record_should_raise_already_processed_error

     SmsOnRails::Outbound.delete_all

     #get the sms instance
     sms = SmsOnRails::Outbound.create_sms 'hi', '2065552476'

     sms.status = 'PROCESSING'
     sms.save!

     #should be unlockable because status is not set to NOT_PROCESSED
     assert_raises(SmsOnRails::LockableRecord::AlreadyProcessed) { sms.deliver! }
  end
end

