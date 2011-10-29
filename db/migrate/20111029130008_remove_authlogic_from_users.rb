class RemoveAuthlogicFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :crypted_password
    remove_column :users, :password_salt
    remove_column :users, :persistence_token
  end

  def down
    add_column :users, :persistence_token, :string
    add_column :users, :password_salt, :string
    add_column :users, :crypted_password, :string
  end
end
