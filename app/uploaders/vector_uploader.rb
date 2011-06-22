class VectorUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick

  # Tent version should be 1 inch high with 600dpi
  version :tent do
    process :vector_to_png => 1.0
  end

  # Letterhead version should be 0.88 inches high with 600dpi
  version :letterhead do
    process :vector_to_png => 0.88
  end

  # Converts vector graphic to png normalized for height in pixels
  def vector_to_png(height_in_inches)
    original = ::Magick::Image.read(current_path).first
    hl_density = (72.0*height_in_inches*600.0)/original.rows.to_f
    wl_density = (72.0*height_in_inches*600.0*4.25)/original.columns.to_f
    density = original.rows.to_f/original.columns.to_f > 4.25 ?  wl_density : hl_density
    image = ::Magick::Image.read(current_path){
      self.density = density.round
      self.transparent_color = '#FFFFFF'
    }.first
    image.write("png:#{self.current_path}")
  end

  def store_dir
    "db/uploads/#{::Rails.env}/logos/vector"
  end

  def extension_white_list
    %w( svg eps )
  end

end

