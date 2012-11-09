class AddMinimumSlotsToPositions < ActiveRecord::Migration
  def up
    add_column :positions, :minimum_slots, :integer
    execute <<-SQL
      UPDATE positions SET minimum_slots = slots;
    SQL
    change_column :positions, :minimum_slots, :integer, null: false
  end

  def down
    remove_column :positions, :minimum_slots
  end
end

