class AddRejectMessageToPosition < ActiveRecord::Migration
  def self.up
    add_column :positions, :reject_message, :text
  end

  def self.down
    remove_column :positions, :reject_message
  end
end
