class CreateMeetingMotions < ActiveRecord::Migration
  def self.up
    create_table :meeting_motions do |t|
      t.references :meeting, :null => false
      t.references :motion, :null => false
      t.text :comment

      t.timestamps
    end
    add_index :meeting_motions, [ :meeting_id, :motion_id ], :unique => true
  end

  def self.down
    drop_index :meeting_motions, [ :meeting_id, :motion_id ]
    drop_table :meeting_motions
  end
end

