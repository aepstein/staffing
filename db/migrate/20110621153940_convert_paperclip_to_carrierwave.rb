class ConvertPaperclipToCarrierwave < ActiveRecord::Migration
  def self.up
    rename_column :users, :resume_file_name, :resume
    rename_column :meetings, :audio_file_name, :audio
    rename_column :meetings, :editable_minutes_file_name, :editable_minutes
    rename_column :meetings, :published_minutes_file_name, :published_minutes
    rename_column :meeting_motions, :introduced_version_file_name, :introduced_version
    rename_column :meeting_motions, :final_version_file_name, :final_version
  end

  def self.down
    rename_column :users, :resume, :resume_file_name
    rename_column :meetings, :audio, :audio_file_name
    rename_column :meetings, :editable_minutes, :editable_minutes_file_name
    rename_column :meetings, :published_minutes, :published_minutes_file_name
    rename_column :meeting_motions, :introduced_version, :introduced_version_file_name
    rename_column :meeting_motions, :final_version, :final_version_file_name
  end
end

