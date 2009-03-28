module SmsOnRails
  module ActsAsSubstitutable

    def self.extended(base)
      base.send :class_inheritable_accessor, :acts_as_sub_options
      base.acts_as_sub_options = {}

      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_substitutable(method, options={})
        
        defaults =  {:time => Proc.new {|rec| Time.now.to_s(:db) }}

        class_eval do
          acts_as_sub_options[method.to_sym] = defaults.merge(options||{})
          def clear_substituted_params
            acts_as_sub_options.keys.each{|method| instance_variable_set("@#{method}", nil)}
          end
        end

        acts_as_substitutable_instance_methods(method)
      end

      protected

      def acts_as_substitutable_instance_methods(method)
        class_eval(<<-EOS, __FILE__, __LINE__)
          before_save :clear_substituted_params

          def substituted_#{method}
            return '' if self.#{method}.blank?
            unless @sub_#{method}
              @sub_#{method} = self.#{method}.dup

              if (subs = @sub_#{method}.scan(substitution_#{method}_regex)).any?
                 subs.flatten.compact.each do |sub|
                   method = #{method}_sub_options[sub.downcase.to_sym]
                   val = if method.is_a?(Proc)
                     method.call(self)
                   elsif method
                     self.send method
                   end
                   @sub_#{method}.gsub!(sub_key_to_val(sub), val)
                 end
              end
            end
            @sub_#{method}
         end

         protected
         def substitution_#{method}_regex
           @@substitution_#{method}_regex ||= 
              Regexp.new #{method}_sub_options.keys.collect{|key| 
                sub_key_to_val(key, ['\\$(', ')\\$'])
              }.join('|')
         end


         def sub_key_to_val(key, surround = ['$', '$'])

           val = surround.first
           val << key.to_s.upcase
           val << surround.last
           val
         end

         def #{method}_sub_options
           self.class.acts_as_sub_options[:#{method}]
         end
       EOS
      end
    end
  end
end

ActiveRecord::Base.extend SmsOnRails::ActsAsSubstitutable unless defined?(ActiveRecord::Base.acts_as_sub_options)


