task :notices => [ 'notices:leave', 'notices:join', 'notices:reject' ]

namespace :notices do

  desc "Send notices for all memberships that have ended"
  task :leave => [ :environment ] do
    Membership.leave_notice_pending.readonly(false).each do |membership|
      membership.send_notice! :leave
      ::Rails.logger.info "Sent leave notice for membership #{membership.id}."
    end
  end

  desc "Send notices for all memberships that have begun"
  task :join => [ :environment ] do
    Membership.join_notice_pending.readonly(false).each do |membership|
      membership.send_notice! :join
      ::Rails.logger.info "Sent join notice for membership #{membership.id}."
    end
  end

  desc "Send notices for all requests that have been rejected"
  task :reject => [ :environment ] do
    Request.reject_notice_pending.readonly(false).each do |request|
      request.send_reject_notice! :reject
      ::Rails.logger.info "Sent reject notice for request #{request.id}."
    end
  end

end

