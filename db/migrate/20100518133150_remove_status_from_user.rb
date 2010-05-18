class RemoveStatusFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :status
  end

  def self.down
    raise IrreversibleMigration
    add_column :users, :status, :string
  end
end

