class UserMailer < ActionMailer::Base


  def renewal_reminder(user, deadline=false, expiration=false)
    subject    'Your Committee Memberships Are Expiring'
    recipients "#{user.name} <#{user.email}>"
    from       'Office of the Assemblies <assembly@cornell.edu>'
    sent_on    Time.now

    body       :user => user, :deadline => deadline ? deadline : Date.today, :expiration => expiration ? expiration : ( Date.today + 3.years )
  end

end

