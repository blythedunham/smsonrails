require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc "Create test database. Run with root permissions. (sudo)"
task :create_test_database do
  system "mysqladmin create sms_on_rails_test"
end

desc "Prepares the test database"
task :prepare_test  do
  require File.dirname(__FILE__) + '/test/run'
  require File.dirname(__FILE__) + '/lib/sms_on_rails/schema_helper'
  instance_eval SmsOnRails::SchemaHelper.schema(:create, 'email_gateway_carrier_table', 'model_tables')
  puts "Seeding SMS tables..."
  require File.dirname(__FILE__) + '/test/test_helper.rb'
  load File.dirname(__FILE__) + '/db/seed_data.rb'
  #system( "ruby #{File.join(File.dirname(__FILE__), '/test/prepare.rb' )} " )
end

desc 'Test the sms_on_rails plugin.'
task :test => [:prepare_test, :test_without_setup]
      

desc 'Test the sms_on_rails plugin without setup'
Rake::TestTask.new(:test_without_setup) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the sms_on_rails plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'SmsOnRails'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


desc 'Copy templates from application files'
task :create_templates do
  dest_dir = File.dirname(__FILE__) + '/generators/sms_on_rails/templates'
  src_dir = File.dirname(__FILE__) + '/../../../app'

  folders = %w( helpers/sms_on_rails helpers/admin/sms_on_rails controllers/admin/sms_on_rails views/layouts/admin/sms_on_rails views/admin/sms_on_rails )
  folders.each do |f|
    puts "Create: #{f}"
    system("rm -r #{dest_dir}/#{f}")
    FileUtils.mkdir_p File.dirname("#{dest_dir}/#{f}")
    system("cp -r #{src_dir}/#{f} #{dest_dir}/#{f}")
  end
end

