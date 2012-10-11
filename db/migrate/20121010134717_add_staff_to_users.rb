class AddStaffToUsers < ActiveRecord::Migration
  class User < ActiveRecord::Base
  end

  def up
    add_column :users, :staff, :boolean, null: false, default: false
    User.reset_column_information
    User.update_all( { staff: true }, { admin: true } )
  end

  def down
    remove_column :users, :staff
  end
end

