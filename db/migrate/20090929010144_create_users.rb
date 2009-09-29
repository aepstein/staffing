class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :first_name, :null => false
      t.string :middle_name
      t.string :last_name, :null => false
      t.string :email, :null => false
      t.string :net_id
      t.string :status

      t.timestamps
    end
    add_index :users, :net_id, :unique => true
  end

  def self.down
    drop_table :users
  end
end

