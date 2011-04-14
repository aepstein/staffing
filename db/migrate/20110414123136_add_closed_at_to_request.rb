class AddClosedAtToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :closed_at, :datetime
    add_index :requests, :closed_at
  end

  def self.down
    remove_index :requests, :closed_at
    remove_column :requests, :closed_at
  end
end

