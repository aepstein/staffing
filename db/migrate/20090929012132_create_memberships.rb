class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.references :user
      t.references :period, :null => false
      t.references :position, :null => false
      t.references :request
      t.date :starts_at, :null => false
      t.date :ends_at, :null => false

      t.timestamps
    end
    add_index :memberships, [ :user_id, :position_id, :period_id ], :unique => true, :name => 'memberships_unique'
  end

  def self.down
    drop_table :memberships
  end
end

