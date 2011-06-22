class AddLogoIdToCommittee < ActiveRecord::Migration
  def self.up
    add_column :committees, :logo_id, :integer
  end

  def self.down
    remove_column :committees, :logo_id
  end
end

