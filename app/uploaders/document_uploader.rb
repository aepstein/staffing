class DocumentUploader < CarrierWave::Uploader::Base

  def extension_white_list
    %w( doc odt docx xls ods xlsx ppt odp pptx pdf txt swf csv )
  end

  # Use mounted_as parameter to give file predictable name
  def filename
    "#{mounted_as}.#{File.extname(original_filename)}" if original_filename
  end

  # Partitions model id in form 000/000/001 for scalable storage
  def partitioned_model_id
    ("%09d" % model.id).scan(/\d{3}/).join("/")
  end

  def store_dir
    "#{::Rails.root}/db/uploads/#{::Rails.env}/#{model.class.arel_table.name}/#{partitioned_model_id}"
  end


end

