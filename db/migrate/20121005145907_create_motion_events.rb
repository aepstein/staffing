class CreateMotionEvents < ActiveRecord::Migration
  def change
    create_table :motion_events do |t|
      t.references :motion, null: false
      t.date :occurrence, null: false
      t.string :event, null: false
      t.text :description

      t.timestamps
    end
    add_index :motion_events, :motion_id
    add_index :motion_events, [ :motion_id, :occurrence ]
  end
end

