class CreateMotionsWatchers < ActiveRecord::Migration
  def up
    create_table :motions_watchers, id: false do |t|
      t.integer :motion_id, null: false
      t.integer :user_id, null: false
    end
    add_index :motions_watchers, [ :motion_id, :user_id ], unique: true
  end

  def down
    remove_index :motions_watchers, [ :motion_id, :user_id ]
    drop_table :motions_watchers
  end
end

