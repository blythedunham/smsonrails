SmsOnRails::ServiceProviders::EmailGateway.config =
{
   :sender => 'youremail address',
   :subject => 'Default Subject Text'
   #:bcc => nil,
   #:mailer_klass => nil
}

#Default inherits from ActionMailer
#SmsOnRails::ServiceProviders::EmailGatewaySupport::SmsMailer.smtp_settings ={}
