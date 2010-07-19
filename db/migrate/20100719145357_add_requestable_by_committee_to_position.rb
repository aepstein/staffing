class AddRequestableByCommitteeToPosition < ActiveRecord::Migration
  def self.up
    add_column :positions, :requestable_by_committee, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :positions, :requestable_by_committee
  end
end

