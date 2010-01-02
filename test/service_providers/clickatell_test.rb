require File.dirname(__FILE__)+'/abstract_test_support.rb'


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

  def test_send_to_bad_clickatell_number
    assert_raise(SmsOnRails::SmsError){
      SmsOnRails::ServiceProviders::Clickatell.instance.send_message('ss', 'test message', options={})
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
