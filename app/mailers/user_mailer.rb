class UserMailer < ActionMailer::Base
  helper :application

  def renew_notice(user)
    @user = user
    mail(
      :to => "#{@user.name} <#{@user.email}>",
      :from => "#{Staffing::Application.app_config['defaults']['authority']['contact_email']}",
      :subject => "Please Specify Your Membership Renewal Preferences"
    )
  end

end

