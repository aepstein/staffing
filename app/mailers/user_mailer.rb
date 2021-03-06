class UserMailer < ActionMailer::Base
  helper :application, :user_mailer

  def renew_notice(user)
    @user = user
    mail(
      to: @user.to_email,
      from: "\"#{Staffing::Application.app_config['defaults']['authority']['contact_name']}\" <#{Staffing::Application.app_config['defaults']['authority']['contact_email']}>",
      subject: "Your action is required to renew committee memberships"
    )
  end

end

