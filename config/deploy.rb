# deploy.rb
set :application, "cicero"
role :app, "assembly.cornell.edu"
role :web, "assembly.cornell.edu"
role :db,  "assembly.cornell.edu", :primary => true

set :user, "www-data"
set :deploy_to, "/var/www/assembly/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git://assembly.cornell.edu/git/#{application}.git"
set :branch, "master"
set :git_enable_submodules, 0

namespace :deploy do
  desc "Tell Passenger to restart the app."
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/uploads #{release_path}/db/uploads"
    run "ln -nfs #{shared_path}/system/production #{release_path}/public/system"
    #run "ln -nfs #{shared_path}/assets #{release_path}/public/assets"
  end

  desc "Sync the public/assets directory."
  task :assets do
    #system "rsync -vr --exclude='.DS_Store' public/assets #{user}@#{application}:#{shared_path}/"
  end

  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end
end

after 'deploy:update_code', 'deploy:symlink_shared', 'deploy:update_crontab'

