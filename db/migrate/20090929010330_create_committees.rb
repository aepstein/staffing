class CreateCommittees < ActiveRecord::Migration
  def self.up
    create_table :committees do |t|
      t.string :name

      t.timestamps
    end
    add_index :committees, :name, :unique => true
  end

  def self.down
    drop_table :committees
  end
end

