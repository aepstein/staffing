class UserMailer < ActionMailer::Base


  def renewal_reminder(user, deadline, expiration)
    subject    'Your Committee Memberships Are Expiring'
    recipients "#{user.name} <#{user.email}>"
    from       'Office of the Assemblies <assembly@cornell.edu>'
    sent_on    Time.now

    body       :user => user, :deadline => deadline, :expiration => expiration
  end

end

