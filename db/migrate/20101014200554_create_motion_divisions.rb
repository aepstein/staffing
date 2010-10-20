class CreateMotionDivisions < ActiveRecord::Migration
  def self.up
    create_table :motion_divisions do |t|
      t.references :divided_motion, :null => false
      t.references :motion, :null => false

      t.timestamp :created_at, :null => false
    end
    add_index :motion_divisions, [ :divided_motion_id, :motion_id ], :unique => true
  end

  def self.down
    drop_index :motion_divisions, [ :divided_motion_id, :motion_id ]
    drop_table :motion_divisions
  end
end

