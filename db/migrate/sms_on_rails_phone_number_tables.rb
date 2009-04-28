    create_table :phone_numbers, :force => true do |t|
      t.string  :number,       :length => 20,  :null => false
      t.integer :carrier_id,                                   :default => nil
      t.integer :owner_id,                                     :default => nil
      t.boolean :white_list,                   :null => false, :default => false
      t.string  :do_not_send,  :length => 30,                  :default => nil
      t.integer :country_code, :length => 2,                   :default => 1
    end

    add_index :phone_numbers, :number, :unique => 'true', :name => 'uk_phone_numbers_number'
    