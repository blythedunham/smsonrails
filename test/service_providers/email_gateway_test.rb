require File.dirname(__FILE__)+'/abstract_test_support.rb'

SmsOnRails::ServiceProviders::EmailGateway.config =
  {
   :sender => 'blythe@spongecell.com',
   :subject => 'Message from SmsOnRails'
   #:bcc => nil,
   #:mailer_klass => nil,
  }


ActionMailer::Base.delivery_method = :test

class SmsOnRails::ServiceProviders::EmailGatewayTest < Test::Unit::TestCase

  include SmsOnRails::ServiceProviders::AbstractTestSupport
  
  protected

  def send_to_phone_data; '12065555555@txt.att.net'; end

  def default_options
    {:phone_number => {:carrier_id => 1}}
  end

  def gateway
    SmsOnRails::ServiceProviders::EmailGateway.instance
  end

end
