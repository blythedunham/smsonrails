require File.dirname(__FILE__)+'/../test_helper'

class SmsOnRails::OutboundTest < Test::Unit::TestCase

  def test_phone_number_saves_digits
    SmsOnRails::PhoneNumber.delete_all
    sms = SmsOnRails::PhoneNumber.create!(:number => '206.555.1234')
    sms.reload
    assert('12065551234', sms.number)

    sms = SmsOnRails::PhoneNumber.create!(:number => '(206)555 - 1235 ')
    sms.reload
    assert('12065551235', sms.number)

    sms = SmsOnRails::PhoneNumber.create!(:number => '1 206)555 - 2222 ')
    sms.reload
    assert('12065552222', sms.number)

    #international
    sms = SmsOnRails::PhoneNumber.create!(:number => '44 206)555 - 3333 ')
    sms.reload
    assert('442065553333', sms.number)

    #international with plus
    sms = SmsOnRails::PhoneNumber.create!(:number => '+206.555.4444')
    sms.reload
    assert('2065554444', sms.number)
  end

  def test_find_by_number
    SmsOnRails::PhoneNumber.delete_all
    test_phone_number_saves_digits

    smses = SmsOnRails::PhoneNumber.find_all_by_numbers(['+206.555.4444', '44 206)555 - 3333 ', '415.555.4444'])
    assert_equal(2, smses.length)

    ['2065554444', '442065553333'].each do |number|
      assert(smses.select{|x| x.number == number })
    end
  end


  def test_find_by_number_and_create
    SmsOnRails::PhoneNumber.delete_all
    test_phone_number_saves_digits

    smses = SmsOnRails::PhoneNumber.find_all_by_numbers(['+206.555.4444', '44 206)555 - 3333 ', '415.555.4444'], :create => true)
    assert_equal(3, smses.length)

    ['2065554444', '442065553333', '4155554444'].each do |number|
      assert(smses.select{|x| x.number == number })
    end
  end

  def test_human_display
    assert_equal('(206) 555-4444', SmsOnRails::PhoneNumber.human_display('206.555.4444'))
    assert_equal('+442065554444',  SmsOnRails::PhoneNumber.human_display('44-206.555.4444'))
  end

end
