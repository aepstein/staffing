task :notices => [ 'notices:leave', 'notices:join', 'notices:reject',
  'notices:renew' ]

namespace :notices do

  desc "Send notices for all memberships that have ended"
  task :leave => [ :environment ] do
    Membership.leave_notice_pending.readonly(false).each do |membership|
      membership.send_leave_notice!
      notices_log "Sent leave notice for membership #{membership.id}."
    end
  end

  desc "Send notices for all memberships that have begun"
  task :join => [ :environment ] do
    Membership.join_notice_pending.readonly(false).each do |membership|
      membership.send_join_notice!
      notices_log "Sent join notice for membership #{membership.id}."
    end
  end

  desc "Send notices for all declined memberships"
  task :decline => [ :environment ] do
    Membership.decline_notice_pending.readonly(false).each do |membership|
      membership.send_decline_notice!
      notices_log "Sent decline notice for membership #{membership.id}."
    end
  end

  desc "Send notices for all requests that have been rejected"
  task :reject => [ :environment ] do
    Request.reject_notice_pending.readonly(false).each do |request|
      request.send_reject_notice!
      notices_log "Sent reject notice for request #{request.id}."
    end
  end

  desc "Send renewal notices for all users having renewal unconfirmed memberships ending +/- 3 months who have not received notice in the last month"
  task :renew => [ :environment ] do
    User.where { id.in( Membership.unscoped.renewal_unconfirmed.
      ends_within( 3.months ).select { user_id } ) }.
      no_renew_notice_since( Time.zone.now - 1.month ).each do |user|
        user.send_renew_notice!
      end
  end

  def notices_log(message)
    ::Rails.logger.info "rake at #{Time.zone.now}: notices: #{message}"
    ::Rails.logger.flush
  end

end

