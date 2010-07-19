class AddNoticeSentAtToMembership < ActiveRecord::Migration
  def self.up
    add_column :memberships, :join_notice_sent_at, :datetime
    add_column :memberships, :leave_notice_sent_at, :datetime
    add_index :memberships, :join_notice_sent_at
    add_index :memberships, :leave_notice_sent_at
  end

  def self.down
    remove_index :memberships, :leave_notice_sent_at
    remove_index :memberships, :join_notice_sent_at
    remove_column :memberships, :leave_notice_sent_at
    remove_column :memberships, :join_notice_sent_at
  end
end

