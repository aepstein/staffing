class CreateSchedules < ActiveRecord::Migration
  def self.up
    create_table :schedules do |t|
      t.string :name

      t.timestamps
    end
    add_index :schedules, :name, :unique => true
  end

  def self.down
    drop_table :schedules
  end
end

