# config valid only for Capistrano 3.1
lock '3.1.0'

set :user, 'www-data'
set :application, 'staffing'
set :repo_url, "git://assembly.cornell.edu/git/#{fetch(:application)}.git"
set :deploy_to, "/var/www/assembly/#{fetch(:application)}"
set :linked_files, %w{config/database.yml config/application.yml}
set :linked_dirs, %w{db/uploads public/system db/fonts log tmp}
set :default_env, {
  "RAILS_RELATIVE_URL_ROOT" => "/staffing"
}
#set :ssh_options, { verbose: :debug }

namespace :deploy do

  task :whoami do
    on roles(:all) do
      execute :whoami
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
