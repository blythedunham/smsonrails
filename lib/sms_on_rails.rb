$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

Dir.glob(File.dirname(__FILE__) + '/sms_on_rails/activerecord_extensions/*.rb'){|f| require f}

files = Dir.glob(File.dirname(__FILE__) + '/sms_on_rails/util/*.rb')
files.concat Dir.glob(File.dirname(__FILE__) + '/sms_on_rails/service_providers/*.rb')
files.concat(Dir.glob(File.dirname(__FILE__) + '/sms_on_rails/model_support/*.rb'))
files.each {|f| require f }
