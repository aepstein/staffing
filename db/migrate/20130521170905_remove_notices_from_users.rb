class RemoveNoticesFromUsers < ActiveRecord::Migration
  def up
    remove_index :users, :renew_notice_at
    remove_column :users, :renew_notice_at
  end

  def down
    add_column :users, :renew_notice_at, :datetime
    add_index :users, :renew_notice_at
  end
end
