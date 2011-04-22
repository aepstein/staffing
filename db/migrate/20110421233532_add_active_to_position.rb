class AddActiveToPosition < ActiveRecord::Migration
  def self.up
    add_column :positions, :active, :boolean, :null => false, :default => true
    add_index :positions, :active
  end

  def self.down
    remove_index :positions, :active
    remove_column :positions, :active
  end
end

