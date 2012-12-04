class AddRolesMaskToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :roles_mask, :integer, null: false, default: false
    add_index :enrollments, :roles_mask
  end
end

