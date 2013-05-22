class AddAppointMessageToCommittees < ActiveRecord::Migration
  def change
    add_column :committees, :appoint_message, :text
  end
end
