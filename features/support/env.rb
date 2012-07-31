require 'rubygems'
require 'spork'

Spork.prefork do
  require 'cucumber/rails'

  Capybara.default_selector = :css

end

Spork.each_run do
  ActionController::Base.allow_rescue = false

  begin
    require 'database_cleaner'
    require 'database_cleaner/cucumber'
    DatabaseCleaner.strategy = :truncation
  rescue NameError
    raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
  end

end

