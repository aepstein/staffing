require 'rubygems'
require 'cucumber/rails'
require 'capybara-screenshot/cucumber'

Capybara.default_selector = :css
ActionController::Base.allow_rescue = false

begin
  require 'database_cleaner'
  require 'database_cleaner/cucumber'
  DatabaseCleaner.strategy = :truncation
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

