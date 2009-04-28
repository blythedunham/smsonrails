class SmsOnRailsController < ApplicationController
  helper SmsOnRails::SmsHelper
  helper SmsOnRails::PhoneNumbersHelper

  include SmsOnRails::CreationSupport


end
