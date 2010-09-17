class AddRejectMessageToAuthority < ActiveRecord::Migration
  def self.up
    add_column :authorities, :reject_message, :text
  end

  def self.down
    remove_column :authorities, :reject_message
  end
end
