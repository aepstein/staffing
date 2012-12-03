class CreateMeetingItemTemplates < ActiveRecord::Migration
  def change
    create_table :meeting_item_templates do |t|
      t.references :meeting_section_template, null: false
      t.string :name, null: false
      t.integer :position, null: false
      t.string :description
      t.integer :duration

      t.timestamps
    end
    add_index :meeting_item_templates, [ :meeting_section_template_id, :name ],
      unique: true, name: 'meeting_item_templates_unique'
  end
end

