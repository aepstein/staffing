class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :attachable_type, null: false
      t.integer :attachable_id, null: false
      t.string :document
      t.string :description, null: false

      t.timestamps
    end
    add_index :attachments, [ :attachable_type, :attachable_id ]
    add_index :attachments, [ :attachable_type, :attachable_id, :description ],
      name: 'unique_description', unique: true
  end
end

