task :notices => [ 'notify:leave', 'notify:join', 'notify:reject' ]

namespace :notices do

  desc "Send notices for all memberships that have ended"
  task :leave => [ :environment ] do
    Membership.leave_notice_pending.each do |membership|
      membership.send_notice! :leave
    end
  end

  desc "Send notices for all memberships that have begun"
  task :join => [ :environment ] do
    Membership.join_notice_pending.each do |membership|
      membership.send_notice! :join
    end
  end

  desc "Send notices for all requests that have been rejected"
  task :reject => [ :environment ] do
    Request.reject_notice_pending.each do |request|
      request.send_reject_notice! :reject
    end
  end

end

