module SmsOnRails
  module LockableRecord

    class UnableToLockRecord < Exception; end
    class AlreadyProcessed   < UnableToLockRecord; end

    
    def self.extended(base)
      base.class_inheritable_hash :locrec_options

      base.locrec_options = {
        :log_lock_warnings => true,
        :columns => {
          :status        => 'status',
          :processed_on  => 'processed_on',
          :notes         => 'notes',
          :retry_count   => 'retry_count',
          :sub_status    => 'sub_status'
        },

        :status => {
          :not_processed => 'NOT_PROCESSED',
          :processed     => 'PROCESSED',
          :processing    => 'PROCESSING',
          :failed        => 'FAILED',
          :cancelled     => 'CANCELLED'
        }
      }

      base.send :include, InstanceMethods
      base.send :extend,  ClassMethods
    end


    module InstanceMethods
      def locrec_columns
        self.class.locrec_columns
      end
      def locrec_status
        self.class.locrec_status
      end

      def already_processed?
        get_locrec_col(:status) != locrec_status[:not_processed]
      end
      # Lock the record by setting the status from NOT_PROCESSED TO PROCESSED
      # StalerecordErrors are caught and logged
      def lock_record
        if already_processed?
          raise SmsOnRails::LockableRecord::AlreadyProcessed.new(
            "Record #{self.to_param} appears to be processed. #{locrec_columns[:status]}" +
            " is #{get_locrec_col(:status)} instead of #{locrec_status[:not_processed]}"
          )
        end

        begin
          set_locrec_col :processed_on, Time.now
          set_locrec_col :status,       locrec_status[:processing]
          set_locrec_col :retry_count,  get_locrec_col(:retry_count).to_i + 1
          save!
          return true
        #this just means another proc got to it first, skip
        rescue ActiveRecord::StaleObjectError => exc
          if locrec_options[:log_lock_warnings]
            log_locrec_error :level => :warn,
                              :msg => "#{self.class} lock failed",
                              :exception => exc
          end
          raise SmsOnRails::LockableRecord::UnableToLockRecord.new(
              "Unable to set #{locrec_columns[:status]}. Record is stale")

        end
        false
      end

      def lock_record_and_execute(&block)

        begin
          # Lock the process, execute the block, set the status to PROCESSED
          # If the process could not be locked (stale record exception), continue without error
          # If the process raised any other exception, set the status to FAILED
          if lock_record
            yield

            if get_locrec_col(:status) == locrec_status[:processing]
              set_locrec_col :status, locrec_status[:processed]
              set_locrec_col :processed_on, Time.now if locrec_columns[:processed_on]
              save!
            end
          end
          return true
        # Do not mess with the record status if it is already being processed
        #rescue ActiveRecord::StaleObjectError => soe
        #  reset_status(locrec_status[:failed], soe)
        
        #rescue self.class.locrec_options[:fatal_exception] => ie
        #  reset_status(locrec_status[:failed], ie)
        #  raise ie
        #

        # Set status to failed and reraise exception if the exception is fatal
        # or we wish to throw all errors
        rescue Exception => exc
          reset_locrec_status(locrec_status[:failed], exc) unless exc.is_a?(SmsOnRails::LockableRecord::UnableToLockRecord)
          raise exc
        end
      end

      def reset_locrec_status(current_status, exc)
        begin
          #log_entry = LogEntry.error("Send #{self.to_s.demodulize} unexpected error: #{self.id}",nil,exc)
          #fresh copy in case it was updated
          reload
          if get_locrec_col(:status) == locrec_status[:processing]

            set_locrec_col :status, current_status

            if locrec_columns[:notes]
              set_locrec_col :notes, "#{current_status}: #{exc.to_s}"
            end

            if locrec_columns[:sub_status] && exc.respond_to?(:sub_status)
              set_locrec_col :sub_status, exc.sub_status.to_s
            end
            
            save!
          end
        rescue Exception => e2
          log_locrec_error(:level => :fatal, :msg => "fatal fatal error in #{self.class}", :exception => e2)
        end
      end

      def log_locrec_error(options={})
        message = options[:msg]||"ERROR LOCKING INSTANCE #{self}"
        message << "\n#{options[:exception].to_s}" if options[:exception]
        logger.send options[:level]||:error, message
      end

      def set_locrec_col(col, value)
        send "#{locrec_columns[col]}=", value
      end

      def get_locrec_col(col)
        send locrec_columns[col]
      end
    end

    module ClassMethods

      def lockable_record(options={})
        self.locrec_options = ActiveRecord::Base.locrec_options.merge(options)
        [:columns, :status].each do |method|
          if options[method]
            self.locrec_options[method] = ActiveRecord::Base.locrec_options[method].merge(options[method])
          end
        end
      end

      def locrec_columns; locrec_options[:columns]; end
      def locrec_status; locrec_options[:status]; end

      def recover_stale_records
        update_all(["#{locrec_columns[:status]} = ?", locrec_status[:not_processed]],
                   stale_record_conditions)
      end


      def delete_stale_records
        delete_all stale_record_conditions
      end

      def stale_record_conditions
        query = []
        query << "#{locrec_columns[:status]} = :status"
        query << "#{locrec_columns[:processed_on]} < now() - interval :min minute"
        map = {:status => locrec_status[:processing],
               :min => locrec_options[:recover_stalled_minutes]}
        [query.join(' AND '), map]
      end
    end
  end
end

ActiveRecord::Base.extend SmsOnRails::LockableRecord unless defined?(ActiveRecord::Base.locrec_options)


