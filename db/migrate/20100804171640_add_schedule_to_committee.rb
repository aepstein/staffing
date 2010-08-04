class AddScheduleToCommittee < ActiveRecord::Migration
  def self.up
    add_column :committees, :schedule_id, :integer
    Committee.reset_column_information
    if Committee.count > 0
      Schedule.reset_column_information
      schedule = Schedule.first
      schedule ||= Schedule.create!(:name => 'Default')
      Committee.update_all( "schedule_id = #{schedule.id}" )
    end
    change_column :committees, :schedule_id, :integer, :null => false
  end

  def self.down
    remove_column :committees, :schedule_id
  end
end

