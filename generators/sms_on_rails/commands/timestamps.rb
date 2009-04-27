Rails::Generator::Commands::Create.class_eval do

  #overwrite next migration string to add a count to the timestamp
  def next_migration_string(padding = 3)#:nodoc:
    if ActiveRecord::Base.timestamped_migrations
      time_str = Time.now.utc.strftime("%Y%m%d%H%M%S")
      time_str << "#{migration_count}" if migration_count > 1
      time_str
    else
      "%.#{padding}d" % next_migration_number
    end
  end

  def migration_count
    @@mig_count||=0
  end

  def increment_migration_count
    @@mig_count = migration_count + 1
  end

  # When creating a migration, it knows to find the first available file in db/migrate and use the migration.rb template.
  def migration_template(relative_source, relative_destination, template_options = {})#:nodoc:
    increment_migration_count
    migration_directory relative_destination
    migration_file_name = template_options[:migration_file_name] || file_name
    if migration_exists?(migration_file_name)
      logger.exists "#{existing_migrations(migration_file_name).first}"
    else
      template(relative_source, "#{relative_destination}/#{next_migration_string}_#{migration_file_name}.rb", template_options)
    end
  end
end
