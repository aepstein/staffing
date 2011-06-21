class MeetingAudioUploader < CarrierWave::Uploader::Base
  include CarrierWave::Compatibility::Paperclip

  storage :file

  def paperclip_path
    ':rails_root/db/uploads/:rails_env/meetings/:id_partition/:attachment/:style.:extension'
  end

  def extension_white_list
    %w( mp3 )
  end

end

