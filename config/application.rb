require File.expand_path('../boot', __FILE__)

require 'rails/all'

APP_CONFIG = YAML.load(File.read(File.expand_path('../application.yml', __FILE__)))[Rails.env]

Bundler.require(:default, Rails.env) if defined?(Bundler)

module Staffing
  class Application < Rails::Application
    config.autoload_paths += %W(#{Rails.root}/lib)
    config.encoding = "utf-8"
    config.filter_parameters += [ :password, :password_confirmation ]
    config.time_zone = 'Eastern Time (US & Canada)'
    config.action_mailer.default_url_options = { :host => "assembly.cornell.edu", :protocol => 'https' }
    config.action_view.javascript_expansions[:defaults] = %w(jquery jquery-ui jquery-ui-timepicker-addon autocomplete-rails rails)
  end
end

