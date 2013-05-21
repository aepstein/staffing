class RemoveNoticesFromMembershipRequests < ActiveRecord::Migration
  def up
    remove_index :membership_requests, :reject_notice_at
    remove_index :membership_requests, :close_notice_at
    remove_column :membership_requests, :reject_notice_at
    remove_column :membership_requests, :close_notice_at
  end

  def down
    add_column :membership_requests, :close_notice_at, :datetime
    add_column :membership_requests, :reject_notice_at, :datetime
    add_index :membership_requests, :reject_notice_at
    add_index :membership_requests, :close_notice_at
  end
end
