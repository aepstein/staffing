class AddRejectMessageToCommittee < ActiveRecord::Migration
  def self.up
    add_column :committees, :reject_message, :text
  end

  def self.down
    remove_column :committees, :reject_message
  end
end
