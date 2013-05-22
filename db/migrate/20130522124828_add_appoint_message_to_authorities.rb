class AddAppointMessageToAuthorities < ActiveRecord::Migration
  def change
    add_column :authorities, :appoint_message, :text
  end
end
