class DropSessions < ActiveRecord::Migration
  def up
    remove_index :sessions, :session_id
    remove_index :sessions, :updated_at
    drop_table :sessions
  end

  def down
    raise IrreversibleMigration
  end
end

