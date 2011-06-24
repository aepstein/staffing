CarrierWave.configure do |config|
  if ::Rails.env.test? or ::Rails.env.cucumber?
    config.storage = :file
    config.enable_processing = false
  end
  config.root = ::Rails.root.join('tmp')
  config.cache_dir = 'carrierwave'
end

