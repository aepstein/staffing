class AddRejectedByToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :rejected_by_user_id, :integer
    add_column :requests, :rejected_by_authority_id, :integer
  end

  def self.down
    remove_column :requests, :rejected_by_authority_id
    remove_column :requests, :rejected_by_user_id
  end
end
