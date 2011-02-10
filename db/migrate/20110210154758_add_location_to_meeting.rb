class AddLocationToMeeting < ActiveRecord::Migration
  def self.up
    add_column :meetings, :location, :string
    execute "UPDATE meetings SET location = 'UNKNOWN'"
    change_column :meetings, :location, :string, :null => false
  end

  def self.down
    remove_column :meetings, :location
  end
end

