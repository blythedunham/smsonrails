require File.dirname(__FILE__)+'/abstract_test_support.rb'

SmsOnRails::ServiceProviders::Clickatell.config =
  {
   :api_id => '3159098',
   :user_name => 'blythedunham',
   :password => 'g1raff3'
  }



class SmsOnRails::ServiceProviders::ClickatellTest < Test::Unit::TestCase
  include SmsOnRails::ServiceProviders::AbstractTestSupport

  def setup
    super
    SmsOnRails::ServiceProviders::Base.default_service_provider = SmsOnRails::ServiceProviders::Clickatell
  end

  def teardown
    super
    SmsOnRails::ServiceProviders::Base.default_service_provider = SmsOnRails::ServiceProviders::Dummy
  end

  def test_send_to_bad_number

    sms = SmsOnRails::Outbound.create_sms 'some test message #{Time.now.to_s(:db)}', 'ss'
    assert_raise(SmsOnRails::SmsError){
      SmsOnRails::ServiceProviders::Clickatell.instance.send_sms sms
    }
  end

  def test_fatal_connection_error
    old_config = SmsOnRails::ServiceProviders::Clickatell.config.dup
    SmsOnRails::ServiceProviders::Clickatell.config[:password] = 'asdfsadfGirafe'
    SmsOnRails::ServiceProviders::Clickatell.instance.send :eval, '@@api = nil'
    assert_raise(SmsOnRails::FatalSmsError){

      SmsOnRails::ServiceProviders::Clickatell.instance.authenticate
    }

  ensure
    SmsOnRails::ServiceProviders::Clickatell.config = old_config
  end
  

end
