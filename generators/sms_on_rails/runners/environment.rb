
  append_file 'config/environment.rb', <<-EOD

SmsOnRails::ServiceProviders::Clickatell.config =
{
   :api_id => 'api-key',
   :user_name => 'username',
   :password => 'password'
}

SmsOnRails::ServiceProviders::EmailGateway.config =
{
   :sender => 'youremail address',
   :subject => 'Default Subject Text'
   #:bcc => nil,
   #:mailer_klass => nil
}

#Default inherits from ActionMailer
#SmsOnRails::ServiceProviders::EmailGatewaySupport::SmsMailer.smtp_settings ={}

#Uncomment out your default SMS sender
#SmsOnRails::ServiceProviders::Base.default_service_provider ||= SmsOnRails::ServiceProviders::Clickatell.instance
#SmsOnRails::ServiceProviders::Base.default_service_provider ||= SmsOnRails::ServiceProviders::EmailGateway.instance

EOD
