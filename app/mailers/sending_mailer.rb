class SendingMailer < ActionMailer::Base
  helper :application

  def sending(sending)
    @sending = sending
    mail(
      :to => "#{sending.user.name} <#{sending.user.email}>",
      :from => "#{Staffing::Application.app_config['defaults']['authority']['contact_email']}",
      :subject => sending.message.subject
    )
  end

end

