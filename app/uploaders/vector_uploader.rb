class VectorUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick

  # Letterhead version should be 1 inch high with 600dpi
  version :tent do
    # Density for 600 pixel height
  end

  # Letterhead version should be 0.88 inches high with 600dpi
  version :letterhead do
    # Density for 528 pixel height
  end

  def store_dir
    "db/uploads/#{::Rails.env}/logos/vector"
  end

  def extension_white_list
    %w( svg eps )
  end

end

