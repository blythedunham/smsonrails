require File.dirname(__FILE__)+'/../test_helper'

#require 'ruby-debug'

class SmsOnRails::DeliveryAndLockingTest  < Test::Unit::TestCase

  def test_outbound_bad_number
    SmsOnRails::Outbound.delete_all

    assert_raises(SmsOnRails::SmsError) {
      sms = SmsOnRails::Outbound.send_immediately 'hi', 'aa'
    }

    sms = SmsOnRails::Outbound.find :first
    assert(sms)

    assert_equal('FAILED', sms.status)
    assert(sms.processed_on.to_i <= Time.now.to_i)
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

  def test_deliver_already_processed_record_should_raise_unlockable_error

     SmsOnRails::Outbound.delete_all

     #get the sms instance
     sms = SmsOnRails::Outbound.create_sms 'hi', '2065552476'

     sms.status = 'PROCESSING'
     sms.save!

     #should be unlockable because status is not set to NOT_PROCESSED
     assert_raises(SmsOnRails::LockableRecord::UnableToLockRecord) { sms.deliver! }
  end
end

