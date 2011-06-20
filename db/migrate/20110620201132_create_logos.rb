class CreateLogos < ActiveRecord::Migration
  def self.up
    create_table :logos do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :logos
  end
end
