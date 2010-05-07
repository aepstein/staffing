class MembershipMailer < ActionMailer::Base


  def join_notice(membership)
    subject    "Your appointment to #{membership.description}"
    recipients "#{membership.user.name} <#{membership.user.email}>"
    from       "#{membership.position.authority.contact_name} <#{membership.position.authority.contact_email}>"
    sent_on    Time.now

    body       :membership => membership
  end

  def leave_notice(sent_at = Time.now)
    subject    'MembershipMailer#leave_notice'
    recipients ''
    from       ''
    sent_on    sent_at

    body       :greeting => 'Hi,'
  end

end

