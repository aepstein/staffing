class AddStartsAtEndsAtPositionToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :starts_at, :date
    add_column :requests, :ends_at, :date
    add_column :requests, :position, :integer
    add_column :requests, :requestable_id, :integer
    add_column :requests, :requestable_type, :string
    remove_column :requests, :position_id
    drop_table :periods_requests
  end

  def self.down
    remove_column :requests, :position
    remove_column :requests, :ends_at
    remove_column :requests, :starts_at
  end
end

