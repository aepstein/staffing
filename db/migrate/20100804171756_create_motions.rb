class CreateMotions < ActiveRecord::Migration
  def self.up
    create_table :motions do |t|
      t.references :period, :null => false
      t.string :name, :null => false
      t.text :description
      t.references :user, :null => false
      t.references :committee, :null => false
      t.boolean :complete, :null => false, :default => false
      t.integer :position
      t.string :status, :null => false

      t.timestamps
    end
    add_index :motions, [ :position, :period_id, :committee_id ], :unique => true, :name => 'unique_position'
    add_index :motions, [ :name, :period_id, :committee_id ], :unique => true, :name => 'unique_name'
  end

  def self.down
    drop_table :motions
  end
end

