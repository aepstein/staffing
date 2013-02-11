class AddSponsorToCommittees < ActiveRecord::Migration
  def change
    add_column :committees, :sponsor, :boolean, null: false, default: true
  end
end

