class AddAttachmentsAudioEditableMinutesAndPublishedMinutesToMeeting < ActiveRecord::Migration
  def self.up
    add_column :meetings, :audio_file_name, :string
    add_column :meetings, :audio_content_type, :string
    add_column :meetings, :audio_file_size, :integer
    add_column :meetings, :audio_updated_at, :datetime
    add_column :meetings, :editable_minutes_file_name, :string
    add_column :meetings, :editable_minutes_content_type, :string
    add_column :meetings, :editable_minutes_file_size, :integer
    add_column :meetings, :editable_minutes_updated_at, :datetime
    add_column :meetings, :published_minutes_file_name, :string
    add_column :meetings, :published_minutes_content_type, :string
    add_column :meetings, :published_minutes_file_size, :integer
    add_column :meetings, :published_minutes_updated_at, :datetime
  end

  def self.down
    remove_column :meetings, :audio_file_name
    remove_column :meetings, :audio_content_type
    remove_column :meetings, :audio_file_size
    remove_column :meetings, :audio_updated_at
    remove_column :meetings, :editable_minutes_file_name
    remove_column :meetings, :editable_minutes_content_type
    remove_column :meetings, :editable_minutes_file_size
    remove_column :meetings, :editable_minutes_updated_at
    remove_column :meetings, :published_minutes_file_name
    remove_column :meetings, :published_minutes_content_type
    remove_column :meetings, :published_minutes_file_size
    remove_column :meetings, :published_minutes_updated_at
  end
end
