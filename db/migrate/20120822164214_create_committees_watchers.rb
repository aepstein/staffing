class CreateCommitteesWatchers < ActiveRecord::Migration
  def up
    create_table :committees_watchers, id: false do |t|
      t.integer :committee_id, null: false
      t.integer :user_id, null: false
    end
    add_index :committees_watchers, [ :committee_id, :user_id ], unique: true
  end

  def down
    remove_index :committees_watchers, [ :committee_id, :user_id ]
    drop_table :committees_watchers
  end
end

