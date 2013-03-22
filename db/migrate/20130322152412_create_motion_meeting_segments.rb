class CreateMotionMeetingSegments < ActiveRecord::Migration
  def change
    create_table :motion_meeting_segments do |t|
      t.references :motion, null: false
      t.references :meeting_item
      t.integer :position, null: false
      t.integer :minutes_from_start
      t.string :description
      t.text :content

      t.timestamps
    end
    add_index :motion_meeting_segments, [ :motion_id, :position ]
    add_index :motion_meeting_segments, :meeting_item_id
  end
end

