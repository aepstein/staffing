class AddRenewableToPosition < ActiveRecord::Migration
  def self.up
    add_column :positions, :renewable, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :positions, :renewable
  end
end

