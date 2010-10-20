class CreateMotionMergers < ActiveRecord::Migration
  def self.up
    create_table :motion_mergers do |t|
      t.references :merged_motion, :null => false
      t.references :motion, :null => false

      t.timestamp :created_at, :null => false
    end
    add_index :motion_mergers, [ :merged_motion_id, :motion_id ], :unique => true
  end

  def self.down
    drop_index :motion_mergers, [ :merged_motion_id, :motion_id ]
    drop_table :motion_mergers
  end
end

