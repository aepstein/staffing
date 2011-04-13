class UserMailer < ActionMailer::Base
  helper :application, :user_mailer

  def renew_notice(user)
    @user = user
    mail(
      :to => "#{@user.name} <#{@user.email}>",
      :from => "#{Staffing::Application.app_config['defaults']['authority']['contact_email']}",
      :subject => "Your Action is Required to Renew Committee Memberships"
    )
  end

end

