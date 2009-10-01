class CreatePositions < ActiveRecord::Migration
  def self.up
    create_table :positions do |t|
      t.references :authority
      t.references :quiz
      t.references :schedule
      t.integer :slots
      t.string :name

      t.timestamps
    end
    add_index :positions, [ :authority_id, :name ], :unique => true
  end

  def self.down
    drop_table :positions
  end
end

