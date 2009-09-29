class CreatePositions < ActiveRecord::Migration
  def self.up
    create_table :positions do |t|
      t.references :authority
      t.references :committee
      t.references :quiz
      t.references :schedule
      t.integer :slots
      t.boolean :voting
      t.string :name

      t.timestamps
    end
    add_index :positions, [ :committee_id, :name ], :unique => true
  end

  def self.down
    drop_table :positions
  end
end

