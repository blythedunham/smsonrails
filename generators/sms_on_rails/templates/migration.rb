class <%= migration_name %> < ActiveRecord::Migration
  def self.up
<%= SmsOnRails::SchemaHelper.create(*files) %>
  end

  def self.down
<%= SmsOnRails::SchemaHelper.drop(*files) %>
  end
end
