class VectorUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick

  # Tent version should be 1 inch high with 600dpi
  version :tent do
    process :vector_to_png_inches => 1.0
    def filename; substitute_extension super, 'png'; end
  end

  # Letterhead version should be 0.88 inches high with 600dpi
  version :letterhead do
    process :vector_to_png_inches => 0.88
    def filename; substitute_extension super, 'png'; end
  end

  # Thumbnail version should be within 100x100 pixel box
  version :thumb do
    process :vector_to_png_pixels => 100.0
    def filename; substitute_extension super, 'png'; end
  end

  # Converts vector graphic to png normalized for height in pixels
  def vector_to_png_inches(height_in_inches)
    original = ::Magick::Image.read(current_path).first
    hl_density = (72.0*height_in_inches*600.0)/original.rows.to_f
    wl_density = (72.0*height_in_inches*600.0*4.25)/original.columns.to_f
    density = original.rows.to_f/original.columns.to_f > 4.25 ?  wl_density : hl_density
    original.destroy!
    vector_to_png density
  end

  # Converts vector graphic to png fitting within square of specified pixels
  def vector_to_png_pixels(pixels)
    original = ::Magick::Image.read(current_path).first
    density = [ original.columns, original.rows ].map { |dimension| (72.0*pixels/dimension).floor }.min
    original.destroy!
    vector_to_png density
  end

  def vector_to_png(density)
    image = ::Magick::Image.read(current_path){
      self.density = density.round
      self.transparent_color = '#FFFFFF'
    }.first
    image.write("png:#{self.current_path}")
    image.destroy!
  end

  # Replace filename extension with chosen alternative
  def substitute_extension(filename, extension)
    filename.chomp(File.extname(filename)) + ".#{extension}"
  end

  def store_dir
    "#{::Rails.root}/db/uploads/#{::Rails.env}/#{model.class.arel_table.name}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w( svg eps )
  end

end

