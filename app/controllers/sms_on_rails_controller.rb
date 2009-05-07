class SmsOnRailsController < ApplicationController
  helper SmsOnRails::SmsHelper
  helper SmsOnRails::PhoneNumbersHelper

  include SmsOnRails::CreationSupport
  layout 'sms_on_rails/basic.html'

  def index
     respond_to do |format|
      format.html { render :action => 'index.html.erb' }
    end
  end

end
