class AddStatusesMaskToPosition < ActiveRecord::Migration
  def self.up
    add_column :positions, :statuses_mask, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :positions, :statuses_mask
  end
end

