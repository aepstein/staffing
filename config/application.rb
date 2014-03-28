require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  Bundler.require(:default, Rails.env)
end


module Staffing
  class Application < Rails::Application
    config.autoload_paths += %W(#{Rails.root}/lib)
    config.encoding = "utf-8"
    config.filter_parameters += [ :password, :password_confirmation ]
    config.time_zone = 'Eastern Time (US & Canada)'
    config.action_mailer.default_url_options = { :host => "assembly.cornell.edu/staffing", :protocol => 'https' }
    config.autoload_paths << "#{Rails.root}/app/reports"
    config.assets.enabled = true
    config.assets.version = '1.1'

    def self.app_config
      @@app_config ||= YAML.load(File.read(File.expand_path('../application.yml', __FILE__)))[Rails.env]
    end
    
    def self.sso_providers
      @@app_config_sso_providers ||= if app_config['sso_providers']
        app_config['sso_providers']
      else
        {}
      end
    end

  end
end

