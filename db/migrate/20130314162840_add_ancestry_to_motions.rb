class AddAncestryToMotions < ActiveRecord::Migration
  class Motion < ActiveRecord::Base; has_ancestry; end

  def up
    add_column :motions, :ancestry, :string
    add_index :motions, :ancestry
    add_column :motions, :parent_id, :integer
    Motion.reset_column_information
    Motion.transaction do
      Motion.lock(true).all
      Motion.update_all "parent_id = referring_motion_id"
      Motion.build_ancestry_from_parent_ids!
      Motion.check_ancestry_integrity!
    end
    remove_column :motions, :parent_id
  end

  def down
    remove_index :motions, :ancestry
    remove_column :motions, :ancestry
  end
end

