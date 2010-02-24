class AddRequestableToPosition < ActiveRecord::Migration
  def self.up
    add_column :positions, :requestable, :boolean
  end

  def self.down
    remove_column :positions, :requestable
  end
end
