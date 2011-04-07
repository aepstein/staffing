class AddRenewalConfirmedAtToMembership < ActiveRecord::Migration
  def self.up
    add_column :memberships, :renewal_confirmed_at, :datetime
    add_index :memberships, :renewal_confirmed_at
  end

  def self.down
    remove_index :memberships, :renewal_confirmed_at
    remove_column :memberships, :renewal_confirmed_at
  end
end

