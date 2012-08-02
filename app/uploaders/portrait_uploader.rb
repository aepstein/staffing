class PortraitUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick

  def extension_white_list
    %w( jpg )
  end

  version :small do
    process resize_to_fill: [300,300]
  end

  version :thumb do
    process resize_to_fill: [100,100]
  end

  # Use mounted_as parameter to give file predictable name
  def filename
    return "#{mounted_as}" if super.blank?
    "#{mounted_as}#{File.extname(super)}"
  end

  # Partitions model id in form 000/000/001 for scalable storage
  def partitioned_model_id
    ("%09d" % model.id).scan(/\d{3}/).join("/")
  end

  def store_dir
    "#{::Rails.root}/db/uploads/#{::Rails.env}/#{model.class.arel_table.name}/#{partitioned_model_id}"
  end


end

