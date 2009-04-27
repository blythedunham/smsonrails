class <%= migration_name %> < ActiveRecord::Migration
  def self.up
<%= SmsOnRails::SchemaHelper.create(*files) %>

<% if migration_name.downcase.include?('carrier') -%>
  require "#{RAILS_ROOT}/vendor/plugins/smsonrails/db/seed_data.rb"
<% else %>
  <%= migration_name %>
<% end -%>
  end

  def self.down
<%= SmsOnRails::SchemaHelper.drop(*files) %>
  end
end
