require File.dirname(__FILE__)+'/../test_helper'

#require 'ruby-debug'

class SmsOnRails::DraftTest  < Test::Unit::TestCase

  def setup
    super
    SmsOnRails::PhoneNumber.delete_all
  end

  def test_create_draft_with_nested_params_with_existing_phone
    phone = SmsOnRails::PhoneNumber.create!(:number => '12065557777')
    test_create_draft_with_nested_params
  end

  def test_create_draft_with_nested_params
    draft = SmsOnRails::Draft.create_sms(test_params)

    validate_draft draft
  end

  def test_create_draft_with_exception
    args = test_params.dup
    args['outbounds_attributes']['0']['phone_number_attributes'].update('number' => 'ss' )
    assert_raises(ActiveRecord::RecordInvalid) { SmsOnRails::Draft.create_sms!(args) }

  end

  def test_create_draft_with_nested_params_with_error
    args = test_params.dup
    args['outbounds_attributes']['0']['phone_number_attributes'].update('number' => 'ss' )

    draft = SmsOnRails::Draft.create_sms(args)

    assert(draft)
    assert(draft.errors.any?)
    assert(draft.new_record?)
    assert('Test Draft', draft.message)

    assert(draft.outbounds)
    assert_equal(1, draft.outbounds.length)
    assert('NOT PROCESSED', draft.outbounds.first.status)
    assert(draft.outbounds.first.new_record?)

    assert(draft.outbounds.first.phone_number)
    assert(draft.outbounds.first.phone_number.new_record?)
    assert('12065557777', draft.outbounds.first.phone_number.number)
    
  end
  
  def test_params
    params = {"draft"=>{"deliver_after(1i)"=>"", "message"=>"Test Draft", "deliver_after(2i)"=>"", "outbounds_attributes"=>{"0"=>{"phone_number_attributes"=>{"number"=>"12065557777", "carrier_id"=>"5"}}}, "deliver_after(3i)"=>"", "deliver_after(4i)"=>"", "deliver_after(5i)"=>""}, "commit"=>"Send Sms", "authenticity_token"=>"XGchwHjmN2j77X27pgxhxOq/hOKWmouy27oMrPWhlUA=", "send_immediately"=>"true", "previous_action"=>"new"}
    params['draft']
  end

  protected
  def validate_draft(draft, options={})
    assert(draft)
    assert(!draft.new_record?)
    assert('Test Draft', draft.message)

    assert(draft.outbounds)
    assert_equal(1, draft.outbounds.length)
    assert('NOT PROCESSED', draft.outbounds.first.status)
    assert(!draft.outbounds.first.new_record?)

    assert(draft.outbounds.first.phone_number)
    assert(!draft.outbounds.first.phone_number.new_record?)
    assert('12065557777', draft.outbounds.first.phone_number.number)
  end
end
