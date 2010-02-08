class CreateDesignees < ActiveRecord::Migration
  def self.up
    create_table :designees do |t|
      t.references :membership, :null => false
      t.references :user, :null => false
      t.references :committee, :null => false
    end
    add_index :designees, [ :membership_id, :committee_id ], :unique => true
  end

  def self.down
    drop_table :designees
  end
end

