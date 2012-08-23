class AddManagerToEnrollments < ActiveRecord::Migration
  class Enrollment < ActiveRecord::Base
  end

  def up
    add_column :enrollments, :manager, :boolean, null: false, default: false
    Enrollment.reset_column_information
    Enrollment.update_all( { manager: true }, { membership_notices: true } )
  end

  def down
    remove_column :enrollments, :manager, :boolean
  end
end

