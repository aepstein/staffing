class PositionRequestableNotNull < ActiveRecord::Migration
  def self.up
    change_column :positions, :requestable, :boolean, :null => false, :default => false
  end

  def self.down
    change_column :positions, :requestable, :boolean, :null => true, :default => nil
  end
end

