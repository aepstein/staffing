class AddPublishedToMeetings < ActiveRecord::Migration
  def change
    add_column :meetings, :published, :boolean, null: false, default: false
  end
end

