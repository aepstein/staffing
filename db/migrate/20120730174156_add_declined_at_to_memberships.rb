class AddDeclinedAtToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :declined_at, :datetime
    add_column :memberships, :declined_by_user_id, :integer
    add_column :memberships, :decline_comment, :text
  end
end

