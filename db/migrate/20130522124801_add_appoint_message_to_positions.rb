class AddAppointMessageToPositions < ActiveRecord::Migration
  def change
    add_column :positions, :appoint_message, :text
  end
end
