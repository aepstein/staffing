class AddAttachmentIntroducedVersionFinalVersionToMeetingMotion < ActiveRecord::Migration
  def self.up
    add_column :meeting_motions, :introduced_version_file_name, :string
    add_column :meeting_motions, :introduced_version_content_type, :string
    add_column :meeting_motions, :introduced_version_file_size, :integer
    add_column :meeting_motions, :introduced_version_updated_at, :datetime
    add_column :meeting_motions, :final_version_file_name, :string
    add_column :meeting_motions, :final_version_content_type, :string
    add_column :meeting_motions, :final_version_file_size, :integer
    add_column :meeting_motions, :final_version_updated_at, :datetime
  end

  def self.down
    remove_column :meeting_motions, :introduced_version_file_name
    remove_column :meeting_motions, :introduced_version_content_type
    remove_column :meeting_motions, :introduced_version_file_size
    remove_column :meeting_motions, :introduced_version_updated_at
    remove_column :meeting_motions, :final_version_file_name
    remove_column :meeting_motions, :final_version_content_type
    remove_column :meeting_motions, :final_version_file_size
    remove_column :meeting_motions, :final_version_updated_at
  end
end
