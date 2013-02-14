class AddDurationToMeetings < ActiveRecord::Migration
  class Meeting < ActiveRecord::Base; end

  def up
    add_column :meetings, :duration, :integer
    Meeting.reset_column_information
    Meeting.update_all "duration = ROUND( ( UNIX_TIMESTAMP( ends_at ) - UNIX_TIMESTAMP( starts_at ) ) / 60 )"
    change_column :meetings, :duration, :integer, null: false
    remove_column :meetings, :ends_at
  end

  def down
    add_column :meetings, :ends_at, :datetime
    Meeting.reset_column_information
    Meeting.update_all "ends_at = #{Meeting.date_add :starts_at, :duration, :minutes}"
    change_column :meetings, :ends_at, :datetime, null: false
    remove_column :meetings, :duration, :integer
  end
end

