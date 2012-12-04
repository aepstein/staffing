class RemoveBooleanRolesFromEnrollments < ActiveRecord::Migration
  def up
    say_with_time "Converting boolean flags to masked roles" do
      # Chair has mask value of 1
      execute <<-SQL
        UPDATE enrollments SET roles_mask = roles_mask + 1
        WHERE manager = #{connection.quote true}
        AND roles_mask & 1 = 0
      SQL
      # Monitor has mask value of 4
      execute <<-SQL
        UPDATE enrollments SET roles_mask = roles_mask + 4
        WHERE membership_notices = #{connection.quote true}
        AND roles_mask & 4 = 0
      SQL
    end
    remove_column :enrollments, :membership_notices
    remove_column :enrollments, :manager
  end

  def down
    add_column :enrollments, :manager, :boolean, default: false, null: false
    add_column :enrollments, :membership_notices, :boolean, default: false, null: false
    say_with_time "Converting masked roles with boolean flags" do
      # Chair has mask value of 1
      execute <<-SQL
        UPDATE enrollments SET manager = true
        WHERE roles_mask & 1 > 0
      SQL
      # Monitor has mask value of 4
      execute <<-SQL
        UPDATE enrollments SET membership_notices = true
        WHERE roles_mask & 4 > 0
      SQL
    end
  end
end

