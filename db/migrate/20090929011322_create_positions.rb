class CreatePositions < ActiveRecord::Migration
  def self.up
    create_table :positions do |t|
      t.references :authority
      t.references :quiz
      t.references :schedule
      t.integer :slots
      t.string :name
      t.text :join_message
      t.text :leave_message

      t.timestamps
    end
    add_index :positions, [ :authority_id, :name ], :unique => true
    create_table :positions_qualifications, :id => false do |t|
      t.references :position, :null => false
      t.references :qualification, :null => false
    end
    add_index :positions_qualifications, [ :position_id, :qualification_id ], :unique => true
  end

  def self.down
    drop_table :positions_qualifications
    drop_table :positions
  end
end

