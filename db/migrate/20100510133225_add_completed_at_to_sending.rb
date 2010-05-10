class AddCompletedAtToSending < ActiveRecord::Migration
  def self.up
    add_column :sendings, :completed_at, :datetime
  end

  def self.down
    remove_column :sendings, :completed_at
  end
end
