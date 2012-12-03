class AddMeetingTemplateIdToCommittees < ActiveRecord::Migration
  def change
    add_column :committees, :meeting_template_id, :integer
    add_index :committees, :meeting_template_id
  end
end

