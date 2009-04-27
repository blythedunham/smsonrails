module SmsOnRails
  class SchemaHelper
    class << self
      def create(*files)
        each_file(*files) {|file, options| file_to_string(file, options) }
      end

      def drop(*files)
        each_file(*files) {|file, options| drop_tables(file, options)}
      end

      def each_file(*files, &block)
        options = parse_options(files)
        files.inject('') {|str, f| str << yield(f, options); str }
      end

      def schema(command, *files)
        str = "ActiveRecord::Schema.define do\n"
        str << self.send(command, *files)
        str << "\nend"
        str
      end

      def file_to_string(file, options={})
        File.read(File.join(File.dirname(__FILE__), "../../db/migrate/#{file}.rb"))
      end

      def drop_tables(file, options={})
        str = "\n"
        data = file_to_string(file)
        data.scan(/create_table\s+[":]([^\W]*)/) do
          table_name = $1.dup
          str << safe_code(str, options) { |code| code << "    drop_table :#{table_name}\n" }
        end
        str
      end

      def safe_code(str, options, &block)
        str = ''
        str << "  begin\n  " if options[:safe]
        yield str
        str << "  rescue Exception => e\n  end\n" if options[:safe]
        str
      end

      def parse_options(files)
        options = files.last.is_a?(Hash) ? files.pop : {}
      end
    end
  end
end
