class CreateQualifications < ActiveRecord::Migration
  def self.up
    create_table :qualifications do |t|
      t.string :name, :null => false
      t.text :description

      t.timestamps
    end
    create_table :qualifications_users, :id => false do |t|
      t.references :qualification, :null => false
      t.references :user, :null => false
    end
    add_index :qualifications, :name, :unique => true
    add_index :qualifications_users, [ :qualification_id, :user_id ], :unique => true
  end

  def self.down
    drop_table :qualifications_users
    drop_table :qualifications
  end
end

