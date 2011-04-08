class DropSendings < ActiveRecord::Migration
  def self.up
    drop_table :sendings
  end

  def self.down
    create_table :sendings do |t|
      t.integer  :user_id
      t.integer  :message_id
      t.string   :message_type
      t.datetime :created_at
      t.datetime :completed_at
    end
  end
end

