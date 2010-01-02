require 'rubygems'
gem 'activesupport', :version => ">= 2.0.0"
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'test/unit'

dir = File.dirname(__FILE__)

ActiveRecord::Base.logger = Logger.new("debug.log")

config = ActiveRecord::Base.configurations['test'] = {
  :adapter  => "mysql",
  :username => "root",
  :encoding => "utf8",
  :host => '127.0.0.1',
  :database => 'sms_on_rails_test' }

ActiveRecord::Base.establish_connection( config )
