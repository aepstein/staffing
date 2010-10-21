class CreateMotionMergers < ActiveRecord::Migration
  def self.up
    create_table :motion_mergers do |t|
      t.references :merged_motion, :null => false
      t.references :motion, :null => false

      t.timestamp :created_at, :null => false
    end
    add_index :motion_mergers, :merged_motion_id, :unique => true
    add_index :motion_mergers, :motion_id
  end

  def self.down
    remove_index :motion_mergers, :motion_id
    remove_index :motion_mergers, :merged_motion_id
    drop_table :motion_mergers
  end
end

