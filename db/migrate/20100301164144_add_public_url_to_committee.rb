class AddPublicUrlToCommittee < ActiveRecord::Migration
  def self.up
    add_column :committees, :public_url, :string
  end

  def self.down
    remove_column :committees, :public_url
  end
end
