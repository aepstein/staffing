class AddContactToAuthority < ActiveRecord::Migration
  def self.up
    add_column :authorities, :contact_name, :string, :null => false, :default => APP_CONFIG['defaults']['authority']['contact_name']
    add_column :authorities, :contact_email, :string, :null => false, :default => APP_CONFIG['defaults']['authority']['contact_email']
  end

  def self.down
    remove_column :authorities, :contact_email
    remove_column :authorities, :contact_name
  end
end

