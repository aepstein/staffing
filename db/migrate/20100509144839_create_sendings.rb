class CreateSendings < ActiveRecord::Migration
  def self.up
    create_table :sendings do |t|
      t.references :user
      t.references :message, :polymorphic => true
      t.datetime :created_at
    end
    add_index :sendings, [ :user_id, :message_id, :message_type ], :unique => true
  end

  def self.down
    drop_table :sendings
  end
end

