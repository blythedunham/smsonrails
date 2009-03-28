require 'action_mailer'
module SmsOnRails
  module ServiceProviders
    module EmailGatewaySupport
      class SmsMailer < ::ActionMailer::Base
        def sms_through_gateway(recipient, message, phone_options={})
          recipients    recipient
          bcc           phone_options[:bcc]
          from          phone_options[:sender]
          subject       phone_options[:subject]
          body          :message => message, :options => phone_options
          template      phone_options[:template] if phone_options[:template]
          content_type  'text/plain'
        end
      end
    end
  end
end

SmsOnRails::ServiceProviders::EmailGatewaySupport::SmsMailer.template_root = File.dirname(__FILE__) + '/../../../'
SmsOnRails::ServiceProviders::EmailGatewaySupport::SmsMailer.logger ||= ActiveRecord::Base.logger