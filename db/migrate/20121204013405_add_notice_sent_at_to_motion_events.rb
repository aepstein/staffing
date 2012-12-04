class AddNoticeSentAtToMotionEvents < ActiveRecord::Migration
  def change
    add_column :motion_events, :notice_sent_at, :datetime
    add_index :motion_events, :notice_sent_at
  end
end

