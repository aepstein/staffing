require 'whenever/capistrano'

set :application, "staffing"
role :app, "kvm02.assembly.cornell.edu"
role :web, "kvm02.assembly.cornell.edu"
role :db,  "kvm02.assembly.cornell.edu", :primary => true

set :user, "www-data"
set :deploy_to, "/var/www/assembly/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git://assembly.cornell.edu/git/#{application}.git"
set :branch, "master"
set :git_enable_submodules, 0

set :whenever_command, 'bundle exec whenever'

namespace :deploy do
  desc "Tell Passenger to restart the app."
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/application.yml #{release_path}/config/application.yml"
    run "ln -nfs #{shared_path}/uploads #{release_path}/db/uploads"
    run "ln -nfs #{shared_path}/system/production #{release_path}/public/system"
    run "ln -nfs #{shared_path}/db/fonts #{release_path}/db/fonts"
    #run "ln -nfs #{shared_path}/assets #{release_path}/public/assets"
  end
end

after 'deploy:update_code', 'deploy:symlink_shared'

