require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "smsonrails"
    gem.summary = %Q{Sms on Rails provides your app with instant SMS integration}
    gem.description = %Q{Sms on Rails provides your app with instant SMS integration}
    gem.email = "blythe@snowgiraffe.com"
    gem.homepage = "http://github.com/blythedunham/smsonrails"
    gem.authors = ["Blythe Dunham"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.add_development_dependency "clickatell", ">= 0"
    gem.add_dependency 'activesupport', ">=2.0.0"
    gem.add_dependency 'static_record_cache'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

desc 'Default: run unit tests.'
task :default => :test

desc "Create test database. Run with root permissions. (sudo)"
task :create_test_database do
  system "mysqladmin create sms_on_rails_test"
end

desc "Prepares the test database"
task :prepare_test  do
  require File.dirname(__FILE__) + '/test/run'

  migration_dir = File.dirname(__FILE__), ""
  #ActiveRecord::Migrator.migrate("db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)

  require File.dirname(__FILE__) + '/lib/sms_on_rails/schema_helper'
  puts SmsOnRails::SchemaHelper.schema(:create, 'sms_on_rails_carrier_tables',  'sms_on_rails_phone_number_tables', 'sms_on_rails_model_tables' )
  instance_eval SmsOnRails::SchemaHelper.schema(:create, 'sms_on_rails_carrier_tables',  'sms_on_rails_phone_number_tables', 'sms_on_rails_model_tables' )
  puts "Seeding SMS tables..."
  require File.dirname(__FILE__) + '/test/test_helper.rb'
  load File.dirname(__FILE__) + '/db/seed_data.rb'

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

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }


