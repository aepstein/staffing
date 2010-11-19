require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  require File.dirname(__FILE__) + '/factories.rb'

  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.mock_with :rspec
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = true
    config.include ActionDispatch::TestProcess
    config.after(:all) do
      data_directory = File.expand_path(File.dirname(__FILE__) + "../../db/uploads/#{::Rails.env}")
      if File.directory?(data_directory)
        FileUtils.rm_rf data_directory
      end
    end
  end
end

Spork.each_run do
end

