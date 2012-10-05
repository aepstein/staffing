class CreateMotionEvents < ActiveRecord::Migration
  def change
    create_table :motion_events do |t|
      t.references :motion, null: false
      t.date :effective_on, null: false
      t.string :event, null: false
      t.text :description

      t.timestamps
    end
    add_index :motion_events, :motion_id
    add_index :motion_events, [ :motion_id, :effective_on ]
  end
end

