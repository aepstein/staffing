class MembershipMailer < ActionMailer::Base


  def join_notice(membership)
    subject    "Your appointment to #{membership.description}"
    recipients "#{membership.user.name} <#{membership.user.email}>"
    from       "#{membership.position.authority.effective_contact_name} <#{membership.position.authority.effective_contact_email}>"
    sent_on    Time.zone.now

    body       :membership => membership
  end

  def leave_notice(membership)
    subject    "Expiration of your appointment to #{membership.description}"
    recipients "#{membership.user.name} <#{membership.user.email}>"
    from       "#{membership.position.authority.effective_contact_name} <#{membership.position.authority.effective_contact_email}>"
    sent_on    Time.zone.now

    body       :membership => membership
  end

end

