class AddDeclineNoticeAtToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :decline_notice_at, :datetime
  end
end
