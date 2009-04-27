class SmsOnRailsUpdatePhoneNumbers < ActiveRecord::Migration
  def self.up

<%
      existing_columns = ActiveRecord::Base.connection.columns(:phone_numbers).collect { |each| each.name }
      columns = [
        [:number,      't.string  :number,       :length => 20, :null => false'],
        [:carrier_id,  't.integer :carrier_id,   :default => nil'],
        [:owner_id,    't.integer :owner_id,     :default => nil'],
        [:white_list,  't.boolean :white_list,   :null => false, :default => false'],
        [:do_not_send, 't.string  :do_not_send,  :length => 30, :default => nil'],
        [:country_code,'t.string  :country_code, :length => 2, :default => 1'],
      ].delete_if {|c| existing_columns.include?(c.first.to_s)}
-%>
    change_table(:phone_numbers) do |t|
<% columns.each do |c| -%>
      <%= c.last %>
<% end -%>
    end

<%
    existing_indexes = ActiveRecord::Base.connection.indexes(:phone_numbers)
    index_names = existing_indexes.collect { |each| each.name }
    new_indexes = [
      [:uk_phone_numbers_number, 'add_index :phone_numbers, :unique => true']
    ].delete_if { |each| index_names.include?(each.first.to_s) }
-%>
<% new_indexes.each do |each| -%>
    <%= each.last %>
<% end -%>
  end

  def self.down
    change_table(:phone_numbers) do |t|
<% unless columns.empty? -%>
      t.remove <%= columns.collect { |each| ":#{each.first}" }.join(',') %>
<% end -%>
    end
  end
end