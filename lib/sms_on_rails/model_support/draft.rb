module SmsOnRails
  module ModelSupport
    module Draft

      def self.included(base)#:nodoc
        base.send :accepts_nested_attributes_for, :outbounds
        #base.acts_as_deliverable :fatal_exception => SmsOnRails::FatalSmsError

        base.validates_presence_of  :message
        base.validate :validates_message_length

        base.class_inheritable_accessor  :default_header
        base.class_inheritable_accessor  :default_footer
        base.class_inheritable_accessor  :max_message_length
        
        base.max_message_length = SmsOnRails::ServiceProviders::Base.max_characters

        base.validates_associated :outbounds

        base.send :include, InstanceMethods
        base.send :extend,  ClassMethods
      end

      module ClassMethods

        # Create a new sms draft
        # +message+ - can either be a string, an attribute hash (nested ok) or and ActiveRecord
        # +phone_numbers+ - array or single text phone number or phone number . If +message+ is
        #   a nested attributes (Rails 2.3), +phone_numbers+ and +options+ should be blank
        #
        # ===Options
        # <tt>:send_immediately</tt> - Send all outbounds now
        # <tt>:draft</tt> - a hash of attributes for the draft object
        # <tt>:phone_number</tt> - a hash of attributes applied to all +phone_numbers+
        # <tt>:outbound</tt> - a hash of attributes applied to all generated +Outbound+ instances
        #
        # ===Example
        # SmsOnRails::Draft.create_sms('my_message', '9995556667')
        # SmsOnRails::Draft.create_sms('my_message', ['2065556666', '9995556667'])
        #
        # SmsOnRails::Draft.create_sms(params[:draft]) # assume nested with :outbound_attributes
        # SmsOnRails::Draft.create_sms(params[:draft], params[:phone_numbers], :send_immediately => true
        def create_sms(message, phone_numbers=nil, options={})
          draft = create_draft(message)
          draft.attributes = options[:draft] if options[:draft]
          draft.create_outbounds_for_phone_numbers(phone_numbers, options) if phone_numbers
          if draft.send(options[:bang] ? :save! : :save) && options[:send_immediately]
            draft.send(options[:bang] ? :deliver! : :deliver)
          end
          draft
        end

        def create_sms!(message, phone_numbers=nil, options={})
          create_sms(message, phone_numbers, options.reverse_merge(:bang => true, :create => :create!))
        end

        # Create the draft object
        # +options+ - A Draft object, a hash of attributes(can be nested) or a String with the draft message
        def create_draft(options={})
          if options.is_a?(ActiveRecord::Base)
            options
          elsif options.is_a?(Hash)
            new(options)
          elsif options.is_a?(String)
            new(:message => options)
          end
        end
      end

      module InstanceMethods

        def initialize(args={})#:nodoc:
          super args
          default_headers_and_footers
        end

        def save_and_deliver(options={})
          save and deliver(options)
        end

        def save_and_deliver!(options={})
          save! and deliver!(options)
        end

        # The length of the message
        # This does not take into consideration substituted params
        # TODO: adjust max length for substituted params
        def message_length; complete_message.length; end
        def max_message_length; self.class.max_message_length; end

        # default the headers and footers
        def default_headers_and_footers
          self.header ||= self.class.default_header
          self.footer ||= self.class.default_footer
        end

        def complete_message
          complete_message = ""
          complete_message << "#{header}\n" unless header.blank?
          complete_message << message
          complete_message << "\n#{footer}" unless footer.blank?
          complete_message
        end


        # Deliver all the unsent outbound messages
        # +error+ - set this option to add an error message to the draft object
        #
        # This is locked and safe for individual messages
        # but the draft object itself is not locked down,
        # so it can be processed by multiple threads
        def deliver(options={})
          deliver_method = options.delete(:bang) ? :deliver! : :deliver

          success = outbounds.inject(true) do |delivered, o|
            next(delivered) if o.delivered?
            unless o.send(deliver_method, options)
             self.errors.add_to_base("Message could not be delivered to: #{o.phone_number.human_display}") if options[:error]
             delivered = false
            end
            delivered
          end
          self.update_attribute(:status, success ?  'PROCESSED' : 'FAILED')
          success
        end

        def deliver!(options={})
          deliver(options.merge(:bang => true))
        end



        # Create Outbound Instances based on +phone_numbers+ and +options+
        # Refer to SmsOnRails::ModelSupport::Outbound.create_outbounds_from_phone
        def create_outbounds_for_phone_numbers(phone_numbers, options={})
          self.outbounds = self.class.reflections[:outbounds].klass.create_outbounds_for_phone_numbers(phone_numbers, options)
        end


        protected

        # validates the length of the message including the header and footer
        def validates_message_length
          errors.add(:message, "must be less than #{max_message_length} characters") unless message_length < max_message_length
        end

      end
    end
  end
end