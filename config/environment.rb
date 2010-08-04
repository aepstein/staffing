# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

  config.action_controller.session = {
    :key => '_staffing_session', :secret => Proc.new { APP_CONFIG['session_secret'] }
  }

  config.action_controller.session_store = :active_record_store

  config.time_zone = 'Eastern Time (US & Canada)'

  config.gem 'validates_timeliness'
  config.gem 'gettext'
  config.gem 'searchlogic', :source => 'http://gemcutter.org'
  config.gem 'authlogic', :source => 'http://gemcutter.org'
  config.gem 'formtastic', :source => 'http://gemcutter.org'
  config.gem 'calendar_date_select'
  config.gem 'bluecloth', :source => 'http://gemcutter.org'
  config.gem 'cornell_netid', :source => 'http://gemcutter.org'
  config.gem 'cornell_ldap', :source => 'http://gemcutter.org', :version => '>= 1.3.1'
  config.gem 'aasm', :source => 'http://gemcutter.org'
  config.gem 'declarative_authorization', :source => 'http://gemcutter.org'
  config.gem 'will_paginate', :source => 'http://gemcutter.org'
  config.gem 'repeated_auto_complete', :source => 'http://gemcutter.org'
  config.gem 'paperclip', :source => 'http://gemcutter.org'
  config.gem 'blind_date', :source => 'http://gemcutter.org'
  config.gem 'daemons', :source => 'http://gemcutter.org'
  config.gem 'sqlite3-ruby', :lib => 'sqlite3', :version => '!= 1.3.0'

  config.action_mailer.default_url_options = { :host => "assembly.cornell.edu", :protocol => 'https' }
end

