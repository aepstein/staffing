class AddRejectedToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :rejected_at, :datetime
    add_column :requests, :rejection_notice_at, :datetime
    add_column :requests, :rejection_comment, :text
  end

  def self.down
    remove_column :requests, :rejection_comment
    remove_column :requests, :rejection_notice_at
    remove_column :requests, :rejected_at
  end
end

