class Admin::SmsOnRails::BaseController < ApplicationController
  helper SmsOnRails::SmsHelper
  helper SmsOnRails::PhoneNumbersHelper
end
