class AddCommitteeIdToAuthority < ActiveRecord::Migration
  def self.up
    add_column :authorities, :committee_id, :integer
  end

  def self.down
    remove_column :authorities, :committee
  end
end

