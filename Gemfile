source 'http://rubygems.org'
gem 'rails', '~> 4.0.0'
gem 'mysql2'
gem 'rake'
gem 'exception_notification', '~> 4.0'
gem 'validates_timeliness'
gem 'gettext'
gem 'squeel', git: 'git://github.com/activerecord-hackery/squeel'
gem 'ransack'
gem 'ancestry'
gem 'cornell_ldap', '>= 1.3.1'
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'state_machine'
gem 'declarative_authorization',
  git: 'git://github.com/aepstein/declarative_authorization.git',
  branch: 'rails4'
gem 'carrierwave'
gem 'blind_date', '~> 1.0.2'
gem 'acts_as_list', '~> 0.4'
gem 'daemons'
gem 'whenever', require: false
gem 'escape_utils'
gem 'prawn', '~> 1.0.0rc'
gem 'prawn-fast-png', require: 'prawn/fast_png'
gem 'paper_trail', '~> 3.0'
gem 'cornell_assemblies_rails',
  path: '/home/ari/code/cornell-assemblies-rails'
#  git: 'git://assembly.cornell.edu/git/cornell-assemblies-rails.git',
#  branch: '0-0-3'
gem 'cornell-assemblies-branding',
  path: '/home/ari/code/cornell-assemblies-branding'
#  git: 'git://assembly.cornell.edu/git/cornell-assemblies-branding.git',
#  branch: '0-0-3'
gem 'valium', :git => 'git://github.com/jayrowe/valium.git'
gem 'bundler', '~> 1.6.0'
group :production do
  gem 'sass-rails', '~> 4.0.2'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'therubyracer', '~> 0.11.4', require: 'v8'
  gem 'libv8', '~> 3.11.8'
  gem 'execjs'
end
group :development, :test do
  gem 'rspec', '~> 2.12'
  gem 'rspec-rails', '~> 2.12'
  gem 'spring', require: false
  gem 'spring-commands-rspec', require: false
  gem 'spring-commands-cucumber', require: false
end
group :development do
  gem 'ruby-graphviz', require: 'graphviz'
  gem 'capistrano-rails', require: false
end
group :test do
  gem 'test-unit', require: false
  gem 'selenium-webdriver', require: false
  gem 'cucumber', require: false
  gem 'cucumber-rails', require: false
  gem 'database_cleaner', require: false
  gem 'capybara', '~> 2.0'
  gem 'factory_girl_rails', '~> 3.0', require: false
  gem 'launchy'
end

