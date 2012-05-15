class RequestMailer < ActionMailer::Base
  helper :application

  def reject_notice( request )
    @request = request
    mail(
      :to => request.user.to_email,
      :from => "\"#{request.rejected_by_authority.effective_contact_name}\" <#{request.rejected_by_authority.effective_contact_email}>",
      :subject => "Your request for appointment to #{request.committee} was declined"
    )
  end

  def close_notice( request )
    @request = request
    mail(
      :to => request.user.to_email,
      :from => "\"#{Staffing::Application.app_config['defaults']['authority']['contact_name']}\" <#{Staffing::Application.app_config['defaults']['authority']['contact_email']}>",
      :subject => "Your request for appointment to #{request.committee} was approved"
    )
  end


end

