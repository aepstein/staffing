class AddSendingsPopulatedToUserRenewalNotice < ActiveRecord::Migration
  def self.up
    add_column :user_renewal_notices, :sendings_populated, :boolean
  end

  def self.down
    remove_column :user_renewal_notices, :sendings_populated
  end
end
