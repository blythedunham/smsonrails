require 'rails_generator/generators/applications/app/template_runner'

class SmsOnRailsGenerator < Rails::Generator::NamedBase

  default_options  :models_only => false, :carriers_only => false, :skip_migration => false

  def manifest
    @actions = (actions.blank?) ? %w(environment migration) : self.actions
    @actions.sort! #we want environment to run first
    @actions.delete('dependencies') if @actions.include?('environment')

    record do |m|
      @actions.each do |action|
         case(action)
           when 'views' then create_views(m)
           when 'models' then copy_models(m)
           when 'environment' then add_configuation_options
           when 'dependencies' then add_dependencies
           when 'migration' then generate_migration_template(m)
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


  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("-m", "--models-only",
           "Skip the model migration and only migrate phone carriers",
           "Default: false") { |v| options[:models_only] = v }
    opt.on("-c", "--carriers-only",
           "Skip the phone carriers and only migrate the models",
           "Default: false") { |v| options[:carriers_only] = v }
  end

  def create_views(m)
    create_admin_view_files m
    create_helper_files m
    create_controller_files m
    add_sms_routes
  end

  def copy_models(m)
    create_app_files(m, 'models/sms_on_rails', :relative_src => '/../../../lib')
    remove_require_all_models
  end

  def add_sms_routes
    run_template 'sms_on_rails_routes', ['routes', 'sms_on_rails routes']
  end

  def add_configuation_options
   
    add_require_all_models
    add_dependencies
    run_template 'environment', ['updating', 'config/environment.rb with sms configuration']
  end

  def add_dependencies
    logger.log 'gem', 'clickatell'
    logger.log 'plugin', 'static_record_cache'
    run_template 'dependencies'
    #Rails::TemplateRunner.new(File.dirname(__FILE__)+'/runners/dependencies.rb', @destination_root)
  end

  def remove_require_all_models
    run_template 'remove_all_models', ['removing', 'references to vanilla models']
  end

  def add_require_all_models
    if !@actions.include?('models') && !File.exists?(File.join(@destination_root, 'app/models/sms_on_rails'))
      run_template 'add_all_models', ['using', 'all vanilla models']
    end
  end

  def create_admin_view_files(m)
    create_app_files(m, 'views/admin/sms_on_rails')
  end

  def create_helper_files(m)
    create_app_files(m, 'helpers/admin/sms_on_rails')
    create_app_files(m, 'helpers/sms_on_rails')
  end

  def create_controller_files(m)
    create_app_files(m, 'controllers/admin/sms_on_rails')
  end


  #recursively copy files from templates/* to app/*
  def create_app_files(m, dir, options={})
    
    dest_base = options[:dest_base]||'app'
    actual_src = File.join(source_root, options[:relative_src].to_s)

    m.directory(File.join(dest_base, dir))

    Dir.glob(File.join(actual_src, dir, '*')) do |f|
      relative_path = relative_source_path(f, actual_src)
      if File.directory?(f)
        create_app_files(m, relative_path, options)
      else
        m.file(File.join(options[:relative_src].to_s, relative_path) , File.join(dest_base, relative_path))
      end
      
    end
  end

  #path relative to the source root
  def relative_source_path(path, src_base = source_root)
    File.expand_path(path).gsub(File.expand_path(src_base) + '/', '')
  end

  def run_template(template_name, message = nil)
    logger.log message.first, message.last if message
    logger.quiet = true
    Rails::TemplateRunner.new(File.join(File.dirname(__FILE__),'runners', template_name + '.rb'), @destination_root)

  ensure
    logger.quiet = options[:quiet]
  end

  #generate the migration template
  def generate_migration_template(m)
    unless options[:skip_migration]
      m.migration_template 'migration.rb', 'db/migrate', :assigns => {
        :migration_name => "#{migration_file_name.classify}s",
        :files => migration_schema_files
      }, :migration_file_name => migration_file_name
    end
  end

  def migration_file_name
    migration_name = "create_sms_on_rails"
    migration_name << "_models" if options[:models_only]
    migration_name << "_phone_carriers" if options[:carriers_only]
    migration_name
  end
  def migration_schema_files
    unless @migration_files
      @migration_files = []
      @migration_files << 'email_gateway_carrier_table' unless options[:models_only]
      @migration_files << 'model_tables' unless options[:carriers_only]
    end
    @migration_files
  end


end
