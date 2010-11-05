class MembershipMailer < ActionMailer::Base


  def join_notice(membership)
    @membership = membership
    mail(
      :to => "#{membership.user.name} <#{membership.user.email}>",
      :from => "#{membership.position.authority.effective_contact_name} <#{membership.position.authority.effective_contact_email}>",
      :subject => "Your appointment to #{membership.description}"
    )
  end

  def leave_notice(membership)
    @membership = membership
    mail(
      :to => "#{membership.user.name} <#{membership.user.email}>",
      :from => "#{membership.position.authority.effective_contact_name} <#{membership.position.authority.effective_contact_email}>",
      :subject => "Expiration of your appointment to #{membership.description}"
    )
  end

end

