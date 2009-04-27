
    create_table :sms_phone_carriers, :force => true do |t|
      t.string :name,           :length => 100, :null => false
      t.string :email_domain,   :length => 100, :default => nil
      t.string :notes,                          :default => nil
      t.string :options,                        :default => nil
    end

    add_index :sms_phone_carriers, :name, :unique => 'true', :name => 'uk_phone_carriers_name'
