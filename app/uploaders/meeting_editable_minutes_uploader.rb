class MeetingEditableMinutesUploader < CarrierWave::Uploader::Base
  include CarrierWave::Compatibility::Paperclip

  storage :file

  def paperclip_path
    ":rails_root/db/uploads/:rails_env/users/:attachment/:id_partition/:style/:basename.:extension"
  end

  def extension_white_list
    %w( doc odt tex txt )
  end

end

