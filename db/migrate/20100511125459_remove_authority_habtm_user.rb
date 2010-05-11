class RemoveAuthorityHabtmUser < ActiveRecord::Migration
  def self.up
    drop_table :authorities_users
  end

  def self.down
    create_table :authorities_users, :id => false do |t|
      t.references :authority, :null => false
      t.references :user, :null => false
    end
    add_index :authorities_users, [ :authority_id, :user_id ], :unique => true
  end
end

