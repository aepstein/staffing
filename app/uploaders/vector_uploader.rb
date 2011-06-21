class VectorUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick

  # Letterhead version should be 1 inch high with 600dpi
  version :tent do
    resize_to_fit 2550, 600
    convert 'png'
  end

  # Letterhead version should be 0.88 inches high with 600dpi
  version :letterhead do
    resize_to_fit 2244, 528
    convert 'png'
  end

  def store_dir
    "db/uploads/#{::Rails.env}/logos/vector"
  end

  def extension_white_list
    %w( svg )
  end

end

