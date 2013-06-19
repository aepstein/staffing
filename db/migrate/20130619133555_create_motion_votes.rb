class CreateMotionVotes < ActiveRecord::Migration
  def change
    create_table :motion_votes do |t|
      t.references :motion_event, null: false
      t.references :user, null: false
      t.integer :type_code, null: false

      t.timestamps
    end
    add_index :motion_votes, :motion_event_id
    add_index :motion_votes, :user_id
    add_index :motion_votes, [ :motion_event_id, :user_id ], unique: true,
      name: :unique_user_id
  end
end
