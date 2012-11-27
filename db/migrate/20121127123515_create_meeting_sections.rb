class CreateMeetingSections < ActiveRecord::Migration
  def change
    create_table :meeting_sections do |t|
      t.references :meeting, null: false
      t.string :name, null: false
      t.integer :position, null: false

      t.timestamps
    end
    add_index :meeting_sections, :meeting_id
    add_index :meeting_sections, [ :meeting_id, :name ], unique: true
  end
end

