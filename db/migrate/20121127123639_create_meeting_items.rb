class CreateMeetingItems < ActiveRecord::Migration
  def change
    create_table :meeting_items do |t|
      t.references :meeting_section, null: false
      t.references :motion
      t.string :name, null: false
      t.string :description
      t.integer :duration, null: false
      t.integer :position, null: false

      t.timestamps
    end
    add_index :meeting_items, :meeting_section_id
    add_index :meeting_items, :motion_id
    add_index :meeting_items, [ :meeting_section_id, :name ], unique: true
  end
end

