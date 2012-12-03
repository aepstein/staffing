class CreateMeetingTemplates < ActiveRecord::Migration
  def change
    create_table :meeting_templates do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :meeting_templates, :name, unique: true
  end
end

