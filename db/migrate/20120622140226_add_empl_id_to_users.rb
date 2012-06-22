class AddEmplIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :empl_id, :integer
    add_index :users, :empl_id, unique: true
  end
end

