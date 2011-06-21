class CreateLogos < ActiveRecord::Migration
  def self.up
    create_table :logos do |t|
      t.string :name, :null => false
      t.string :vector

      t.timestamps
    end
    add_index :logos, :name, :unique => true
  end

  def self.down
    remove_index :logos, :name
    drop_table :logos
  end
end

