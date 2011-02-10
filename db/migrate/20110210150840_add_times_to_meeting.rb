class AddTimesToMeeting < ActiveRecord::Migration
  def self.up
    add_column :meetings, :starts_at, :datetime
    add_column :meetings, :ends_at, :datetime
    execute "UPDATE meetings SET starts_at = when_scheduled"
    execute "UPDATE meetings SET ends_at = when_scheduled"
    change_column :meetings, :starts_at, :datetime, :null => false
    change_column :meetings, :ends_at, :datetime, :null => false
    remove_column :meetings, :when_scheduled
  end

  def self.down
    add_column :meetings, :when_scheduled
    execute "UPDATE meetings SET when_scheduled = starts_at"
    change_column :meetings, :when_scheduled, :null => false
    remove_column :meetings, :ends_at
    remove_column :meetings, :starts_at
  end
end

