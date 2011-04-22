class AddMembershipNoticesToEnrollment < ActiveRecord::Migration
  def self.up
    add_column :enrollments, :membership_notices, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :enrollments, :membership_notices
  end
end

