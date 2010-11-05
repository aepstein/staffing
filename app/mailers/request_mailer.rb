class RequestMailer < ActionMailer::Base

  def reject_notice(request)
    @request = request
    mail(
      :to => "#{request.user.name} <#{request.user.email}>",
      :from => "#{request.rejected_by_authority.effective_contact_name} <#{request.rejected_by_authority.effective_contact_email}>",
      :subject => "Your request for appointment to #{request.requestable} was declined"
    )
  end


end

