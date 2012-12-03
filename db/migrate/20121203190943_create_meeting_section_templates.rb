class CreateMeetingSectionTemplates < ActiveRecord::Migration
  def change
    create_table :meeting_section_templates do |t|
      t.references :meeting_template, null: false
      t.string :name, null: false
      t.integer :position, null: false

      t.timestamps
    end
    add_index :meeting_section_templates, [ :meeting_template_id, :name ],
      unique: true, name: 'meeting_section_templates_unique'
  end
end

