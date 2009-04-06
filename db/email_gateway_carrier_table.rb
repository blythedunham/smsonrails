    create_table :sms_phone_carriers, :force => true do |t|
      t.column :name, :string, :length => 100
      t.column :email_domain, :string, :length => 100, :default => nil
      t.column :options, :string, :default => nil
    end

    add_index :sms_phone_carriers, :name, :unique => 'true', :name => 'uk_phone_carriers_name'
