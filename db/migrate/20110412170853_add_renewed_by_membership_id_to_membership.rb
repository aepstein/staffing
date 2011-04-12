class AddRenewedByMembershipIdToMembership < ActiveRecord::Migration
  def self.up
    add_column :memberships, :renewed_by_membership_id, :integer
    add_index :memberships, :renewed_by_membership_id
  end

  def self.down
    remove_index :memberships, :renewed_by_membership_id
    remove_column :memberships, :renewed_by_membership_id
  end
end

