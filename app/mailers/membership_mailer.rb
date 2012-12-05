class MembershipMailer < ActionMailer::Base
  MONITOR_ROLES = %w( chair monitor )

  helper :application
  attr_accessor :membership

  def join_notice(m)
    self.membership = m
    mail(
      to: membership.user.to_email,
      cc: membership_monitor_emails,
      from: "\"#{membership.position.authority.effective_contact_name}\" <#{membership.position.authority.effective_contact_email}>",
      subject: "Your appointment to #{membership.description}"
    )
  end

  def leave_notice(m)
    self.membership = m
    mail(
      to: membership.user.to_email,
      cc: membership_monitor_emails,
      from: "\"#{membership.position.authority.effective_contact_name}\" <#{membership.position.authority.effective_contact_email}>",
      subject: "Expiration of your appointment to #{membership.description}"
    )
  end

  def decline_notice(m)
    self.membership = m
    mail(
      to: membership.user.to_email,
      cc: membership_monitor_emails,
      from: "\"#{membership.position.authority.effective_contact_name}\" <#{membership.position.authority.effective_contact_email}>",
      subject: "Renewal of your appointment to #{membership.description} was declined"
    )
  end

  protected

  # These are emails of users who should be copied on membership notices:
  # * assigned peers who have an overlapping monitoring role in a common
  #   committee with a future end date
  def membership_monitor_emails
    @membership_monitor_emails ||= membership.peers.with_roles(MONITOR_ROLES).
      current_or_future.assigned.includes { user }.map(&:user).map(&:to_email)
  end

end

