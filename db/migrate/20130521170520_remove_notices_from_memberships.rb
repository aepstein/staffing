class RemoveNoticesFromMemberships < ActiveRecord::Migration
  def up
    remove_index :memberships, :join_notice_at
    remove_index :memberships, :leave_notice_at
    remove_column :memberships, :join_notice_at
    remove_column :memberships, :leave_notice_at
    remove_column :memberships, :decline_notice_at
  end

  def down
    add_column :memberships, :decline_notice_at, :datetime
    add_column :memberships, :leave_notice_at, :datetime
    add_column :memberships, :join_notice_at, :datetime
    add_index :memberships, :join_notice_at
    add_index :memberships, :leave_notice_at
  end
end
