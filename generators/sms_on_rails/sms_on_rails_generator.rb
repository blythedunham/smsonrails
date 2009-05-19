require 'rails_generator/generators/applications/app/template_runner'
require File.dirname(__FILE__) + '/commands/inserts.rb'
require File.dirname(__FILE__) + '/commands/timestamps.rb'

class SmsOnRailsGenerator < Rails::Generator::NamedBase

  default_options  :skip_models => false,         :skip_carriers => false,
                   :skip_phone_numbers => false,  :skip_migration => false,
                   :default_service_provider =>   :email_gateway

  unless defined?(SERVICE_PROVIDERS)
    SERVICE_PROVIDERS           = [:clickatell, :email_gateway]
    SET_SERVICE_PROVIDER_CONFIG = "SmsOnRails::ServiceProviders::Base.set_default_service_provider"
  end
  
  def manifest
    @actions = (actions.blank?) ? %w(environment migration phone_collision assets) : self.actions
    @actions.sort! #we want environment to run first
    @actions.delete('dependencies') if @actions.include?('environment')

    record do |m|
      @actions.each do |action|
         case(action)
           when 'views'           then create_views(m)
           when 'models'          then copy_models(m)
           when 'environment'     then add_configuation_options(m)
           when 'dependencies'    then add_dependencies(m)
           when 'migration'       then generate_migration_templates(m)
           when 'phone_collision' then handle_phone_number_collision(m)
           when 'assets'          then copy_assets(m)
         end
      end
    end
  end

  def after_generate
  end

  protected

  def banner
    "Usage: #{$0} sms_on_rails setup [models views environment]"
  end

  # options specific to sms on rails generator
  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("-m", "--skip-models",
           "Skip the models migration",
           "Default: false") { |v| options[:skip_models] = v }
    opt.on("-c", "--skip-carriers",
           "Skip the phone carriers migrations",
           "Default: false") { |v| options[:skip_carriers] = v }
    opt.on("-p", "--skip-phone-numbers",
           "Skip the phone numbers migrations",
           "Default: false") { |v| options[:skip_phone_numbers] = v }
    opt.on("-s", "--default-service-provider=[name]",
           "Name of the default service provider: clickatell or email_gateway",
           "Default: email_gateway") { |v| options[:default_service_provider] = v.to_s.downcase.underscore.to_sym }
  end

  # If app/models/phone_number.rb exists, add include the Sms functionality
  # and define app/models/sms_on_rails/phone_number.rb to point to PhoneNumber
  def handle_phone_number_collision(m)
    #if the phone_number.rb file exists on the main
    phone_number_model = "app/models/phone_number.rb"
    if File.exists?(phone_number_model)
      m.insert_into phone_number_model, "include SmsOnRails::ModelSupport::PhoneNumber             # include custom sms on rails phone number handling"
      m.insert_into phone_number_model, "include SmsOnRails::ModelSupport::PhoneNumberAssociations # remove this for custom sms on rails associations"

      sms_on_rails_dir = File.join("app", "models", "sms_on_rails")
      m.directory sms_on_rails_dir
      m.file "phone_number_collision.rb", File.join(sms_on_rails_dir, "phone_number.rb")
    end
  end

  # add sms on rails dependencies such as the clickatell gem and static record cache
  def add_dependencies(m)
    add_clickatell_gem(m) if options[:default_service_provider] == :clickatell
    logger.log 'plugin', 'static_record_cache'
    run_template 'dependencies'
  end

  # add the clickatell gem dependency to the app's config/enviornment.rb file
  def add_clickatell_gem(m)
    logger.log 'gem', 'clickatell'
    m.insert_into 'config/environment.rb', "config.gem 'clickatell'\n",
                  :margin => 2, :insert_after => /Rails::Initializer\.run.*\n/, :quiet => true
  end
  
  #copy up the public folder
  def copy_assets(m)
    create_app_files(m, 'public', :dest_base => '.', :relative_src => '/../../../')
  end

  # Use template runner to run specified template and output message
  def run_template(template_name, message = nil)
    logger.log message.first, message.last if message
    logger.quiet = true
    Rails::TemplateRunner.new(File.join(File.dirname(__FILE__),'runners', template_name + '.rb'), @destination_root)
  ensure
    logger.quiet = options[:quiet]
  end

  # generate the 3 sms on rails migrations by creating them in the main app dir
  def generate_migration_templates(m)
    generate_migration_template(m, :carrier)                          unless options[:skip_carriers]
    generate_migration_template(m, :phone_number, phone_mig_options)  unless options[:skip_phone_numbers]
    generate_migration_template(m, :model)                            unless options[:skip_models]
  end

  #change to update if phone number exists
  def phone_mig_options
    if ActiveRecord::Base.connection.table_exists?(:phone_numbers)
      {:migration_file_name => 'sms_on_rails_update_phone_numbers' }
    else
      {}
    end
  end

  #generate the specified migration template
  def generate_migration_template(m, migration_name, options={})
    return if options[:skip_migration]

    migration_file_name =  options[:migration_file_name]||"sms_on_rails_create_#{migration_name}s"
    template_file_name  = (options[:migration_file_name]||'schema_migration') +'.rb'

    m.migration_template "migrate/#{template_file_name}", 'db/migrate', :assigns => {
      :migration_name => "#{migration_file_name.classify}s",
      :files => ["sms_on_rails_#{migration_name}_tables"]
    }, :migration_file_name => migration_file_name

  end

  def add_configuation_options(m)
    add_require_all_models unless supports_engines?
    add_dependencies(m)

    logger.update "configuration options in environment.rb"
    disable_logger do
      add_service_provider_configuration(m)
      add_default_service_provider(m)
    end
  end

  protected

  def disable_logger(&block)
   logger.quiet = true
   yield
  ensure
    logger.quiet = options[:quiet]
  end

  def add_service_provider_configuration(m)
    SERVICE_PROVIDERS.each do |sp_name|
      config_file = File.dirname(__FILE__) + "/templates/configuration/#{sp_name}.rb"
      if File.exists?(config_file)
        m.insert_into 'config/environment.rb', File.read(config_file),
          :margin => 0, :append => true, :quiet => true,
          :match => "SmsOnRails::ServiceProviders::#{sp_name.to_s.classify}.config"
      end
    end
  end


  def add_default_service_provider(m)
    line = "#{SET_SERVICE_PROVIDER_CONFIG} #{options[:default_service_provider].to_sym.inspect}"

    m.insert_into "config/environment.rb", line, :margin => 0, :quiet => true,
      :replace => Regexp.new("#{SET_SERVICE_PROVIDER_CONFIG}.*(\\n|$)")
  end


  ##############################################################################
  # Pre Rails engine support: copy to app directly
  ##############################################################################

  def create_views(m)
    create_admin_view_files m
    create_helper_files m
    create_controller_files m
    add_sms_routes
  end
  
  def copy_models(m)
    create_app_files(m, 'models/sms_on_rails')
    remove_require_all_models
  end

  def add_sms_routes
    return if supports_engines?
    run_template 'sms_on_rails_routes', ['routes', 'sms_on_rails routes']
  end

  #return true if the rails version has support for engines
  def supports_engines?
    @@supports_engines ||= ActiveRecord::VERSION::STRING >= '2.3.0'
  end

  # remove the require 'sms_on_rails/all_models.rb from environment.rb'
  def remove_require_all_models
    run_template 'remove_all_models', ['removing', 'references to vanilla models']
  end

  # add the require 'sms_on_rails/all_models.rb from environment.rb'
  def add_require_all_models
    if !@actions.include?('models') && !File.exists?(File.join(@destination_root, 'app/models/sms_on_rails'))
      run_template 'add_all_models', ['using', 'all vanilla models']
    end
  end

  # create admin views by copying to main app/views
  def create_admin_view_files(m)
    create_app_files(m, 'views/admin/sms_on_rails')
  end

  # create admin views by copying to main app/helper
  def create_helper_files(m)
    create_app_files(m, 'helpers/admin/sms_on_rails')
    create_app_files(m, 'helpers/sms_on_rails')
  end

  # create admin views by copying to main app/controller
  def create_controller_files(m)
    create_app_files(m, 'controllers/admin/sms_on_rails')
  end

  #recursively copy files from templates/* to app/*
  def create_app_files(m, dir, options={})
    
    dest_base = options[:dest_base]||'app'
    relative_src = (options[:relative_src]||'/../../../app').to_s
    actual_src = File.join(source_root, relative_src)

    m.directory(File.join(dest_base, dir))

    Dir.glob(File.join(actual_src, dir, '*')) do |f|
      relative_path = relative_source_path(f, actual_src)
      if File.directory?(f)
        create_app_files(m, relative_path, options)
      else
        m.file(File.join(relative_src, relative_path) , File.join(dest_base, relative_path))
      end
    end
  end

  #path relative to the source root
  def relative_source_path(path, src_base = source_root)
    File.expand_path(path).gsub(File.expand_path(src_base) + '/', '')
  end

end

