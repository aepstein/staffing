class UnpolymorphizeRequests < ActiveRecord::Migration
  def up
    add_column :requests, :committee_id, :integer
    add_index :requests, [ :user_id, :committee_id ], unique: true
    execute <<-SQL
      UPDATE requests SET committee_id = requestable_id
      WHERE requestable_type = 'Committee'
    SQL
    execute <<-SQL
      DELETE FROM requests WHERE committee_id IS NULL
    SQL
    change_column :requests, :committee_id, :integer, null: false
    remove_index :requests, name: 'unique_user_requestable'
    remove_column :requests, :requestable_type
    remove_column :requests, :requestable_id
  end

  def down
    add_column :requests, :requestable_id, :integer
    add_column :requests, :requestable_type, :string
    add_index :requests, [ :user_id, :requestable_type, :requestable_id ],
      unique: true, name: 'unique_user_requestable'
    execute <<-SQL
      UPDATE requests SET requestable_type = 'Committee',
      requestable_id = committee_id
    SQL
    change_column :requests, :requestable_id, :integer, null: false
    change_column :requests, :requestable_type, :string, null: false
    remove_index :requests, [ :user_id, :committee_id ]
    remove_column :requests, :committee_id
  end
end

