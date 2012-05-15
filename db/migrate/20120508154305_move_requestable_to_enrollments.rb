class MoveRequestableToEnrollments < ActiveRecord::Migration
  def up
    add_column :enrollments, :requestable, :boolean, null: false, default: false
    execute <<-SQL
      UPDATE enrollments SET requestable =
      (SELECT requestable_by_committee FROM positions
      WHERE positions.id = enrollments.position_id)
      WHERE enrollments.committee_id IN
      (SELECT id FROM committees WHERE committees.requestable =
      #{connection.quote true})
    SQL
    remove_column :positions, :requestable
    remove_column :positions, :requestable_by_committee
    remove_column :committees, :requestable
  end

  def down
    add_column :committees, :requestable, null: false, default: false
    add_column :positions, :requestable_by_committee, null: false, default: false
    add_column :positions, :requestable, :boolean, null: false, default: false
    execute <<-SQL
      UPDATE positions SET requestable_by_committee = #{connection.quote true}
      WHERE id IN
      (SELECT position_id FROM enrollments WHERE requestable = #{connection.quote true})
    SQL
    execute <<-SQL
      UPDATE committees SET requestable = #{connection.quote true}
      WHERE id IN
      (SELECT committee_id FROM enrollments WHERE requestable = #{connection.quote true})
    SQL
    remove_column :enrollments, :requestable
  end
end

