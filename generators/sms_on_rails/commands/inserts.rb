# Most of this was derived from the clearance gem work
Rails::Generator::Commands::Base.class_eval do
  def file_contains?(relative_destination, line)
    File.read(destination_path(relative_destination)).include?(line)
  end

  def margin_text(options={})
    margin = ' ' * (options[:margin]||2)
    margin
  end

  def append_to_file(relative_destination, content)
    path = destination_path(relative_destination)
    File.open(path, 'ab') { |file| file.write("\n" + content + "\n") }
  end
end

Rails::Generator::Commands::Create.class_eval do


  def insert_into(file, new_line, options={})
    logger.insert "#{new_line} into #{file}" unless options[:quiet]
    
    line = margin_text(options) + new_line

    unless options[:pretend] || file_contains?(file, options[:match]||line)
      if options[:append]
        append_to_file(file, line)
      else
        gsub_file file, /^(class|module) .+$/ do |match|
          "#{match}\n#{line}"
        end
      end

    end
  end
end

Rails::Generator::Commands::Destroy.class_eval do
  def insert_into(file, line, options={})
    logger.remove "#{line} from #{file}"
    unless options[:pretend]
      gsub_file file, "\n#{margin_text(options)}#{line}", ''
    end
  end
end

Rails::Generator::Commands::List.class_eval do
  def insert_into(file, line)
    logger.insert "#{line} into #{file}"
  end
end
