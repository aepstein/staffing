class CreateRequests < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|
      t.references :term
      t.references :position
      t.references :user
      t.string :state

      t.timestamps
    end
  end

  def self.down
    drop_table :requests
  end
end
