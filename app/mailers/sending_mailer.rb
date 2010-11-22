class SendingMailer < ActionMailer::Base
  helper :application

  def sending(sending)
    @sending = sending
    mail(
      :to => "#{sending.user.name} <#{sending.user.email}>",
      :from => "#{APP_CONFIG['defaults']['authority']['contact_email']}",
      :subject => sending.message.subject
    )
  end

end

