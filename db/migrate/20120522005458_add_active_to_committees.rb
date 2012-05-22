class AddActiveToCommittees < ActiveRecord::Migration
  def change
    add_column :committees, :active, :boolean, null: false, default: true
  end
end

