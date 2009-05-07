class Admin::SmsOnRails::BaseController < ApplicationController
  helper SmsOnRails::SmsHelper
  helper SmsOnRails::PhoneNumbersHelper

  layout 'sms_on_rails/basic.html'

  def index
    
  end

end
