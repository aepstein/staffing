class RemoveStateFromRequest < ActiveRecord::Migration
  def self.up
    remove_column :requests, :state
  end

  def self.down
    add_column :requests, :state, :string
  end
end
