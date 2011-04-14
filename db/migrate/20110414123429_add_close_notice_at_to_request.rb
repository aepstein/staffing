class AddCloseNoticeAtToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :close_notice_at, :datetime
    add_index :requests, :close_notice_at
  end

  def self.down
    remove_index :requests, :close_notice_at
    remove_column :requests, :close_notice_at
  end
end

