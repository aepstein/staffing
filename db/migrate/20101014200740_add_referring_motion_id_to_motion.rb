class AddReferringMotionIdToMotion < ActiveRecord::Migration
  def self.up
    add_column :motions, :referring_motion_id, :integer
    add_index :motions, :referring_motion_id
  end

  def self.down
    drop_index :motions, :referring_motion_id
    remove_column :motions, :referring_motion_id
  end
end

