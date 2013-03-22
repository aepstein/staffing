class AddMeetingIdToMotions < ActiveRecord::Migration
  def change
    add_column :motions, :meeting_id, :integer
  end
end
