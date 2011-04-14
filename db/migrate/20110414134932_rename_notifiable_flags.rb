class RenameNotifiableFlags < ActiveRecord::Migration
  def self.up
    remove_index :memberships, :join_notice_sent_at
    remove_index :memberships, :leave_notice_sent_at
    remove_index :users, :renew_notice_sent_at
    rename_column :requests, :rejection_notice_at, :reject_notice_at
    rename_column :memberships, :leave_notice_sent_at, :leave_notice_at
    rename_column :memberships, :join_notice_sent_at, :join_notice_at
    rename_column :users, :renew_notice_sent_at, :renew_notice_at
    add_index :requests, :reject_notice_at
    add_index :memberships, :leave_notice_at
    add_index :memberships, :join_notice_at
    add_index :users, :renew_notice_at
  end

  def self.down
    remove_index :users, :renew_notice_at
    remove_index :memberships, :join_notice_at
    remove_index :memberships, :leave_notice_at
    remove_index :requests, :reject_notice_at
    rename_column :users, :renew_notice_at, :renew_notice_sent_at
    rename_column :memberships, :leave_notice_at, :leave_notice_sent_at
    rename_column :memberships, :join_notice_at, :join_notice_sent_at
    rename_column :requests, :reject_notice_at, :rejection_notice_at
    add_index :users, :renew_notice_sent_at
    add_index :memberships, :leave_notice_sent_at
    add_index :memberships, :join_notice_sent_at
  end
end

