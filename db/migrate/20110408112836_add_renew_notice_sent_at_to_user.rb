class AddRenewNoticeSentAtToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :renew_notice_sent_at, :datetime
    add_index :users, :renew_notice_sent_at
  end

  def self.down
    remove_column :users, :renew_notice_sent_at
    remove_column :users, :renew_notice_sent_at
  end
end
