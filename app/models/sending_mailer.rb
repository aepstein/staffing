class SendingMailer < ActionMailer::Base


  def sending(sending)
    subject    sending.message.subject
    recipients "#{sending.user.name} <#{sending.user.email}>"
    from       "#{APP_CONFIG['defaults']['authority']['contact_name']} <#{APP_CONFIG['defaults']['authority']['contact_email']}>"
    sent_on    Time.now

    body       :sending => sending
  end

end

