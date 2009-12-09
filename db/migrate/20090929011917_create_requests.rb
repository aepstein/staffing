class CreateRequests < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|
      t.references :position, :null => false
      t.references :user, :null => false
      t.string :state

      t.timestamps
    end
    create_table :periods_requests, :id => false do |t|
      t.references :request, :null => false
      t.references :period, :null => false
    end
    add_index :periods_requests, [ :period_id, :request_id ], :unique => true
  end

  def self.down
    drop_table :periods_requests
    drop_table :requests
  end
end

