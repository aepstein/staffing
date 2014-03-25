namespace :threadsafe do
# desc 'Enable thread-safe mode (enabled by default in production)'
task :enabled do
ENV.delete 'THREADSAFE'
end

# desc 'Disable thread-safe mode'
task :disabled do
ENV['THREADSAFE'] = 'off'
end
end

# Ensure we are always running in single-threaded mode for Rake tasks
Rake::Task['environment'].prerequisites.insert(0, 'threadsafe:disabled')
