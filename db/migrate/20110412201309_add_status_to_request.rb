class AddStatusToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :status, :string, :null => false, :default => 'active'
    add_index :requests, :status
    execute "UPDATE requests SET status = #{connection.quote 'rejected'} " +
      "WHERE rejected_at IS NOT NULL"
  end

  def self.down
    remove_index :requests, :status
    remove_column :requests, :status
  end
end

