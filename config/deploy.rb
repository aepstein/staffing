set :application, "staffing"
set :repository,  "git://assembly.cornell.edu/git/#{application}.git"

set :scm, :git
set :repository, "git://assembly.cornell.edu/git/#{application}.git"
set :branch, "master"
set :git_enable_submodules, 0
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "assembly.cornell.edu"                          # Your HTTP server, Apache/etc
role :app, "assembly.cornell.edu"                          # This may be the same as your `Web` server
role :db,  "assembly.cornell.edu", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

set :user, "www-data"
set :deploy_to, "/var/www/assembly/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false


# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :start {}
  task :stop {}

  desc "Restart service gracefully"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/db/uploads #{release_path}/db/uploads"
    #run "ln -nfs #{shared_path}/assets #{release_path}/public/assets"
  end

  desc "Sync the public/assets directory."
  task :assets do
    #system "rsync -vr --exclude='.DS_Store' public/assets #{user}@#{application}:#{shared_path}/"
  end

#  desc "Update the crontab file"
#  task :update_crontab, :roles => :db do
#    run "cd #{release_path} && whenever --update-crontab #{application}"
#  end
end

#after 'deploy:update_code', 'deploy:symlink_shared', 'deploy:update_crontab'

