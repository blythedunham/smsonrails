ActiveRecord::Base.logger = Logger.new("debug.log")

config = ActiveRecord::Base.configurations['test'] = {
  :adapter  => "mysql",
  :username => "root",
  :encoding => "utf8",
  :host => '127.0.0.1',
  :database => 'sms_on_rails_test' }

ActiveRecord::Base.establish_connection( config )

