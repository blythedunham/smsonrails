require 'active_support'
require File.dirname(__FILE__) + '/../lib/sms_on_rails/schema_helper'

namespace :sms do
  desc 'Reset the Sms data'
  task :reset => [ :teardown, :setup ]

  desc 'Create Tables and seed them'
  task :setup => [ :create_tables, :seed_tables ]

  desc 'Teardown'
  task :teardown => [:drop_tables]
  schema_tables = %w(sms_on_rails_carrier_tables sms_on_rails_phone_number_tables sms_on_rails_model_tables)

  [:create, :drop].each do |command|
    schema_tables.each do |table|
    
      desc "#{command.to_s.titleize} #{table.titleize}"
      task "#{command}_#{table}".to_sym => :environment do
        eval SmsOnRails::SchemaHelper.schema(command, table, :safe => true)
      end

    end
    desc '#{command.to_s.titleize} All SMS database tables'
    task "#{command}_tables".to_sym => schema_tables.collect{|t| "sms:#{command}_#{t}"}
  end

  
  desc 'Seed tables'
  task :seed_tables => :environment do
    puts "Seeding SMS tables..."
    load File.dirname(__FILE__) + '/../db/seed_data.rb'
  end
  
  desc 'Create New Specialized Gateway Template'
  task :create_email_template => :environment do
    raise "Task unavailable to this database (no migration support)" unless ActiveRecord::Base.connection.supports_migrations?

    default_path = 'sms_on_rails/service_providers/email_gateway_support/sms_mailer'
    default_template_name = 'sms_through_gateway.erb'
    dest_path = File.join(ActionMailer::Base.template_root, default_path)
    FileUtils.mkdir_p(dest_path)

    dest = File.join(dest_path, default_template_name)
    unless File.exists?(dest)
      src = File.join(File.dirname(__FILE__), '../lib', default_path, 'sms_through_gateway.erb')
      FileUtils.cp(src, dest)
    end

    config = "\n# Place email gateway templates in the default view directory"
    config << "\n# To configure your sms messages, edit file:"
    config << "\n#  #{dest.gsub(RAILS_ROOT, '')} "

    #relative_root = File.expand_path(ActionMailer::Base.template_root.to_s)
    #relative_root.gsub!(RAILS_ROOT+'/', '/..')
    #config << "File.dirname(__FILE__) + #{relative_root.inspect}\n\n"
    config << "\nSmsOnRails::ServiceProviders::EmailGatewaySupport::SmsMailer.template_root= "
    config << "ActionMailer::Base.template_root\n\n"
    
    File.open(File.join(RAILS_ROOT, 'config/environment.rb'), 'a') {|file| file.puts config }

    puts "environment.rb has been updated to set your new template path."
    puts "Please edit the template in the file:\n #{dest}"
    
  end

end