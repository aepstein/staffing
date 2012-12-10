class UserResumeUploader < CarrierWave::Uploader::Base
  def extension_white_list
    %w( pdf )
  end

  # Use mounted_as parameter to give file predictable name
  def filename
    "#{mounted_as}_#{Time.zone.now.to_s :number}.pdf" if original_filename
  end

  # Partitions model id in form 000/000/001 for scalable storage
  def partitioned_model_id
    ("%09d" % model.id).scan(/\d{3}/).join("/")
  end

  def store_dir
    "#{::Rails.root}/db/uploads/#{::Rails.env}/#{model.class.arel_table.name}/#{partitioned_model_id}"
  end

end

