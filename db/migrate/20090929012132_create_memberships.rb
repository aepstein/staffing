class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.references :user
      t.references :period
      t.references :position
      t.references :request
      t.date :starts_at
      t.date :ends_at

      t.timestamps
    end
    add_index :memberships, [ :user_id, :position_id, :period_id ], :unique => true
  end

  def self.down
    drop_table :memberships
  end
end

