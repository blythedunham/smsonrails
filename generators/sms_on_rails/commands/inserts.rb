# Most of this was derived from the clearance gem work
Rails::Generator::Commands::Base.class_eval do

  # Return true if the file contains the line (String or Regexp)
  def file_contains?(relative_destination, line)
    File.read(destination_path(relative_destination)).scan(line).any?
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

  # Insert the new line into the file
  # +file+ - the name of the file to update
  # +new_line+ - the new line to insert
  # == Options
  # <tt>:quiet</tt> - turn off logging
  # <tt>:append</tt> - when true append to the end of the file instead of <tt>:insert_after</tt>
  # <tt>:match</tt> - (String or Regexp). If the file contents matches then do not add this line again. This defaults to the actual line itself
  # <tt>:replace</tt> - (Regexp) Replace the matching regexp completely with the new line. If nothing matches the replace regexp, append to the end of the file. <tt>:insert_after</tt> value is ignored.
  # <tt>:insert_after</tt> (Regexp) Insert the new line after this match. By default, the line is inserted after a class or module
  # <tt>:margin</tt> - length of the margin to add before the line. Defaults to 2.
  def insert_into(file, new_line, options={})
    logger.insert "#{new_line} into #{file}" unless options[:quiet]
    
    line = margin_text(options) + new_line

    unless options[:pretend] || file_contains?(file, options[:match]||line)
      if options[:append] || (options[:replace] && !file_contains?(file, options[:replace]))
        append_to_file file, line
      else
        regex = options[:insert_after]||options[:replace]||/^(class|module) .+$/
        gsub_file file, regex do |match|
          options[:replace] ? line : "#{match}\n#{line}"
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
