require 'bundler/capistrano'
require 'whenever/capistrano'
load 'deploy' if respond_to?(:namespace)
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy'
load 'deploy/assets'

