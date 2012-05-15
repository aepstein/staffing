require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  if defined?(ActiveRecord::Base)
    begin
      require 'database_cleaner'
      DatabaseCleaner.strategy = :truncation
    rescue LoadError => ignore_if_database_cleaner_not_present
    end
  end

  RSpec.configure do |config|
    config.mock_with :rspec
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = true
    config.include ActionDispatch::TestProcess
    config.include FactoryGirl::Syntax::Methods
    config.before(:all) do
      DatabaseCleaner.clean
    end
    config.after(:all) do
      data_directory = File.expand_path(File.dirname(__FILE__) + "../../db/uploads/#{::Rails.env}")
#      if File.directory?(data_directory)
#        FileUtils.rm_rf data_directory
#      end
    end
  end
end

Spork.each_run do
end

