class MembershipMailer < ActionMailer::Base
  helper :application

  def join_notice(membership)
    @membership = membership
    mail(
      :to => membership.user.to_email,
      :cc => membership.watchers.map(&:to_email),
      :from => "\"#{membership.position.authority.effective_contact_name}\" <#{membership.position.authority.effective_contact_email}>",
      :subject => "Your appointment to #{membership.description}"
    )
  end

  def leave_notice(membership)
    @membership = membership
    mail(
      :to => membership.user.to_email,
      :cc => membership.watchers.map(&:to_email),
      :from => "\"#{membership.position.authority.effective_contact_name}\" <#{membership.position.authority.effective_contact_email}>",
      :subject => "Expiration of your appointment to #{membership.description}"
    )
  end

  def decline_notice(membership)
    @membership = membership
    mail(
      to: membership.user.to_email,
      cc: membership.watchers.map(&:to_email),
      from: "\"#{membership.position.authority.effective_contact_name}\" <#{membership.position.authority.effective_contact_email}>",
      subject: "Renewal of your appointment to #{membership.description} was declined"
    )
  end

end

