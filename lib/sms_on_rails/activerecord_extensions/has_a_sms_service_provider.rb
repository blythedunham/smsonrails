module SmsOnRails
  module ServiceProviders
    module HasASmsServiceProvider

      def self.extended(base)
        base.send :class_inheritable_hash, :sms_service_provider_options
        base.extend ClassMethods
      end

      module ClassMethods
        # Add an accessor to the service provider
        # 
        # 
        # For example, if the provider was referenced by name by calling method 'sms_vendor'
        #   has_an_sms_service_provider :method => 'sms_vendor', :type => :name, :accessor_method => 'sms_service_provider'
        # would define an instance method sms_service_provider and  sms_service_provider_id that returns the appropriate
        # instance and id respectively.
        #
        # Likewise if :type => :id or there is a column on the :id field, sms_service_provider_id would
        # be defined
        #
        #
        # ===Options
        # <tt>:type</tt> the key field (either :id or :name). the one that actually stores the data
        # The provider is referenced by provider_id by default
        # <tt>:method</tt> the name of the method that should be invoked to get the wanted id or name
        # <tt>:accessor_name</tt> the name of the new method accessor
        def has_a_sms_service_provider(options={})
          self.sms_service_provider_options = options||{}

          sms_service_provider_options[:accessor_name]||= 'sms_service_provider'

          accessors =
            { sms_service_provider_options[:accessor_name] + '_id' => :provider_id,
              sms_service_provider_options[:accessor_name] + '_name'=> :name}


          key_field = nil
          if sms_service_provider_options[:type]
            key_field = sms_service_provider_options[:accessor_name]
            key_field << '_'
            key_field << sms_service_provider_options[:type]
          end

          set_instance_code = accessors.inject('') do |code, field|


            # column fields use write_attribute to update the data
            # non column field look up the service providers real name
            if respond_to?(:column_names) && self.column_names.include?(field.first)
              key_field ||= field.first
              code << "write_attribute(#{field.first.inspect}, (@provider.#{field.last} if @provider))"
            else
              class_eval <<-EOS, __FILE__, __LINE__
                def #{field.first}
                  if (p=#{sms_service_provider_options[:accessor_name]})
                    p.send #{field.last.inspect}
                  end
                end
              EOS
            end

            #define the setter function to call the service_provider instance setter
            class_eval <<-EOS, __FILE__, __LINE__
              def #{field.first}=(value)
                self.#{sms_service_provider_options[:accessor_name]}=value
                self.#{field.first}
              end
            EOS
            code
          end

          #define the setter and getter codes for service provider
          class_eval <<-EOS, __FILE__, __LINE__
            def #{sms_service_provider_options[:accessor_name]}
              unless @provider
                value = self.send(#{key_field.inspect})
                self.#{sms_service_provider_options[:accessor_name]}=value
              end
              @provider
            end

            def #{sms_service_provider_options[:accessor_name]}=(value)
              @provider = SmsOnRails::ServiceProviders::Base.get_service_provider(value)
              #{set_instance_code}
              @provider
            end

            def default_service_provider; SmsOnRails::ServiceProviders::Base.default_service_provider; end
            def self.sms_service_provider_map; SmsOnRails::ServiceProviders::Base.provider_map; end
            def self.sms_service_provider_list; SmsOnRails::ServiceProviders::Base.provider_list; end
          EOS
        end
      end
    end
  end
end

unless ActiveRecord::Base.respond_to?(:has_a_sms_service_provider)
  ActiveRecord::Base.extend SmsOnRails::ServiceProviders::HasASmsServiceProvider
end
