class CreateMeetings < ActiveRecord::Migration
  def self.up
    create_table :meetings do |t|
      t.references :committee, :null => false
      t.references :period, :null => false
      t.date :when_scheduled, :null => false

      t.timestamps
    end
    add_index :meetings, [ :committee_id, :when_scheduled ], :unique => true
  end

  def self.down
    drop_table :meetings
  end
end

