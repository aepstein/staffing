class AddRequestableToCommittee < ActiveRecord::Migration
  def self.up
    add_column :committees, :requestable, :boolean
  end

  def self.down
    remove_column :committees, :requestable
  end
end
