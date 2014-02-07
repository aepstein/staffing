role :app, "kvm02.assembly.cornell.edu"
role :web, "kvm02.assembly.cornell.edu"
role :db,  "kvm02.assembly.cornell.edu", primary: true

server 'kvm02.assembly.cornell.edu', user: 'www-data', roles: %w{web app db}
set :deploy_via, :remote_cache
#set :use_sudo, false

#set :git_enable_submodules, 0

namespace :deploy do
  desc "Tell Passenger to restart the app."
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end

#  desc "Symlink shared configs and folders on each release."
#  task :symlink_shared do
#    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
#    run "ln -nfs #{shared_path}/config/application.yml #{release_path}/config/application.yml"
#    run "ln -nfs #{shared_path}/uploads #{release_path}/db/uploads"
#    run "ln -nfs #{shared_path}/system/production #{release_path}/public/system"
#    run "ln -nfs #{shared_path}/db/fonts #{release_path}/db/fonts"
#    #run "ln -nfs #{shared_path}/assets #{release_path}/public/assets"
#  end
end

#after 'deploy:update_code', 'deploy:symlink_shared'
#after 'deploy:update', 'deploy:cleanup'

## Simple Role Syntax
## ==================
## Supports bulk-adding hosts to roles, the primary
## server in each group is considered to be the first
## unless any hosts have the primary property set.
## Don't declare `role :all`, it's a meta role
#role :app, %w{deploy@example.com}
#role :web, %w{deploy@example.com}
#role :db,  %w{deploy@example.com}

## Extended Server Syntax
## ======================
## This can be used to drop a more detailed server
## definition into the server list. The second argument
## something that quacks like a hash can be used to set
## extended properties on the server.
#server 'kvm02.assembly.cornell.edu', user: 'www-data', roles: %w{web app db}

## you can set custom ssh options
## it's possible to pass any option but you need to keep in mind that net/ssh understand limited list of options
## you can see them in [net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start)
## set it globally
##  set :ssh_options, {
##    keys: %w(/home/rlisowski/.ssh/id_rsa),
##    forward_agent: false,
##    auth_methods: %w(password)
##  }
## and/or per server
## server 'example.com',
##   user: 'user_name',
##   roles: %w{web app},
##   ssh_options: {
##     user: 'user_name', # overrides user setting above
##     keys: %w(/home/user_name/.ssh/id_rsa),
##     forward_agent: false,
##     auth_methods: %w(publickey password)
##     # password: 'please use keys'
##   }
## setting per server overrides global ssh_options
