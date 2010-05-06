class AddUniqueOnRequest < ActiveRecord::Migration
  def self.up
    add_index :requests, [ :user_id, :requestable_type, :requestable_id ], :unique => true, :name => 'unique_user_requestable'
  end

  def self.down
    remove_index :requests, :name => :unique_user_requestable
  end
end

