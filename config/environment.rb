RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

if Gem::VERSION >= "1.3.6"
    module Rails
        class GemDependency
            def requirement
                r = super
                (r == Gem::Requirement.default) ? nil : r
            end
        end
    end
end

Rails::Initializer.run do |config|

  config.action_controller.session = {
    :key => '_staffing_session', :secret => Proc.new { APP_CONFIG['session_secret'] }
  }

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
  config.gem 'bluecloth'
  config.gem 'whenever'

  config.action_mailer.default_url_options = { :host => "assembly.cornell.edu", :protocol => 'https' }
end

