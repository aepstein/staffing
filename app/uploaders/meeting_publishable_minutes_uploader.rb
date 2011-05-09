class MeetingPublishableMinutesUploader < CarrierWave::Uploader::Base
  include CarrierWave::Compatibility::Paperclip

  storage :file

  def paperclip_path
    ":rails_root/db/uploads/:rails_env/users/:attachment/:id_partition/:style/:basename.:extension"
  end

  def extension_white_list
    %w( pdf )
  end

  def filename
    "original.pdf" if original_filename
  end

end

