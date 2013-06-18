class AddRoomToMeetings < ActiveRecord::Migration
  def change
    add_column :meetings, :room, :string
  end
end
