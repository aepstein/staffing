class AddConfirmedAtToMembership < ActiveRecord::Migration
  def self.up
    add_column :memberships, :confirmed_at, :datetime
  end

  def self.down
    remove_column :memberships, :confirmed_at
  end
end
