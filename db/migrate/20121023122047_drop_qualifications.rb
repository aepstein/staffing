class DropQualifications < ActiveRecord::Migration
  def up
    remove_index :positions_qualifications, name: 'positions_qualifications_unique'
    drop_table :positions_qualifications
    remove_index :qualifications_users, [ :qualification_id, :user_id ]
    drop_table :qualifications_users
    remove_index :qualifications, :name
    drop_table :qualifications
  end

  def down
    create_table :qualifications do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
    add_index :qualifications, :name, unique: true
    create_table :qualifications_users, id: false do |t|
      t.references :qualification, null: false
      t.references :user, null: false
    end
    add_index :qualifications_users, [ :qualification_id, :user_id ], unique: true
    create_table :positions_qualifications, id: false do |t|
      t.references :position, null: false
      t.references :qualification, null: false
    end
    add_index :positions_qualifications, [ :position_id, :qualification_id ], unique: true, name: 'positions_qualifications_unique'
  end
end

