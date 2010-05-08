class AddContactToAuthority < ActiveRecord::Migration
  def self.up
    add_column :authorities, :contact_name, :string
    add_column :authorities, :contact_email, :string
  end

  def self.down
    remove_column :authorities, :contact_email
    remove_column :authorities, :contact_name
  end
end

