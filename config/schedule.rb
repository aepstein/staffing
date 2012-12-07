set :output, { :standard => nil }
job_type :runner,  'cd :path && bundle exec script/runner -e :environment ":task"'
job_type :rake,    'cd :path && RAILS_ENV=:environment /usr/bin/env bundle exec rake :task --silent :output'

every 1.days do
  rake "email_list:build"
  rake "notices"
end

