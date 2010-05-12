class SendingMailer < ActionMailer::Base


  def sending(s)
    subject       s.message.subject
    recipients    "#{s.user.name} <#{s.user.email}>"
    from          "#{APP_CONFIG['defaults']['authority']['contact_email']}"
    sent_on       Time.now
    content_type  'multipart/alternative'

    part :content_type => 'text/plain', :body => render_message( 'sending.text.plain', :sending => s)
    part :content_type => 'text/html', :body => render_message( 'sending.text.html', :sending => s)
  end

end

