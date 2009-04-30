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

  def test_find_and_create_all_by_numbers
    SmsOnRails::PhoneNumber.delete_all
    test_phone_number_saves_digits

    smses = SmsOnRails::PhoneNumber.find_and_create_all_by_numbers(['+206.555.4444', '44 206)555 - 3333 ', '415.555.4444', '14155554444'], :create => :create!)
    assert_equal(3, smses.length)

    # These are sorted when creating new ones
    ['2065554444', '442065553333', '14155554444'].each_with_index do |number, idx|
      assert(number, smses[idx].number)
    end
  end


  def test_find_and_create_all_by_numbers_with_ar
    SmsOnRails::PhoneNumber.delete_all
    SmsOnRails::PhoneNumber.create!(:number => '44 206)555 - 3333 ')

    list = [SmsOnRails::PhoneNumber.new(:number => '206.555.4444', :carrier_id => 1),
            SmsOnRails::PhoneNumber.new(:number => '44 206)555 - 3333 ', :carrier_id => 2)]

    smses = SmsOnRails::PhoneNumber.find_and_create_all_by_numbers(list, :create => :new)
    assert_equal(2, smses.length)
    
    assert(smses.first.new_record?)

    # These are sorted when creating new ones
    ['12065554444', '442065553333'].each_with_index do |number, idx|
      assert_equal(number, smses[idx].number)
      assert_equal(idx + 1, smses[idx].carrier_id)
    end
  end

    def test_find_and_create_all_by_numbers_with_hash
    SmsOnRails::PhoneNumber.delete_all
    SmsOnRails::PhoneNumber.create!(:number => '44 206)555 - 3333 ')

    list = [SmsOnRails::PhoneNumber.new(:number => '206.555.4444', :carrier_id => 1),
            SmsOnRails::PhoneNumber.new(:number => '44 206)555 - 3333 ', :carrier_id => 2)]
    list.collect!{|x| x.attributes }
    
    smses = SmsOnRails::PhoneNumber.find_and_create_all_by_numbers(list, :create => :new)
    assert_equal(2, smses.length)

    assert(smses.first.new_record?)

    # These are sorted when creating new ones
    ['12065554444', '442065553333'].each_with_index do |number, idx|
      assert_equal(number, smses[idx].number)
      assert_equal(idx + 1, smses[idx].carrier_id)
    end
  end



  def test_sms_carrier_email
    phone = SmsOnRails::PhoneNumber.create!(:carrier_id => 1, :number => '12065557777')
    assert_equal('12065557777', phone.number)
    assert_equal('2065557777@vtext.com', phone.sms_email_address)
  end


  def test_find_and_create_all_by_numbers_with_duplicates
    SmsOnRails::PhoneNumber.delete_all
    test_phone_number_saves_digits

    smses = SmsOnRails::PhoneNumber.find_and_create_all_by_numbers(['+206.555.4444', '44 206)555 - 3333 ', '415.555.4444', '+442065553333'], :create => :create!, :keep_duplicates => true)
    assert_equal(4, smses.length)

    # These are sorted when creating new ones
    ['12065554444', '442065553333', '14155554444', '442065553333'].each_with_index do |number, idx|
      assert_equal(number, smses[idx].number)
    end
  end

  def test_find_all_by_numbers
    SmsOnRails::PhoneNumber.delete_all
    test_phone_number_saves_digits

    smses = SmsOnRails::PhoneNumber.find_all_by_numbers(['+206.555.4444', '44 206)555 - 3333 ', '415.555.4444'])
    assert_equal(2, smses.length)

    ['2065554444', '442065553333'].each do |number|
      assert(smses.select{|x| x.number == number })
    end
  end

  def test_find_by_number_with_finder_options
    SmsOnRails::PhoneNumber.delete_all
    test_phone_number_saves_digits

    sms = SmsOnRails::PhoneNumber.find_by_number('+206.555.4444', :conditions => 'id is not null')
    assert_equal('12065554444', sms.number)
  end


  def test_human_display
    assert_equal('(206) 555-4444', SmsOnRails::PhoneNumber.human_display('206.555.4444'))
    assert_equal('+442065554444',  SmsOnRails::PhoneNumber.human_display('44-206.555.4444'))
  end

end
