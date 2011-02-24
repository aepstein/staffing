class RemoveConfirmedAtFromMembership < ActiveRecord::Migration
  def self.up
    remove_column :memberships, :confirmed_at
  end

  def self.down
    add_column :memberships, :confirmed_at, :datetime
  end
end
