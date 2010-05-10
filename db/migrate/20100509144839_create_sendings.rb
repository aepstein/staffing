class CreateSendings < ActiveRecord::Migration
  def self.up
    create_table :sendings do |t|
      t.references :user
      t.references :message, :polymorphic => true
      t.datetime :created_at
    end
    add_index :sendings, :user_id
    add_index :sendings, [ :message_id, :message_type ]
  end

  def self.down
    drop_table :sendings
  end
end

