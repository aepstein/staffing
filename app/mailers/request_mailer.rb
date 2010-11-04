class RequestMailer < ActionMailer::Base

  def reject_notice(request)
    subject    "Your request for appointment to #{request.requestable} was declined"
    recipients "#{request.user.name} <#{request.user.email}>"
    from       "#{request.rejected_by_authority.effective_contact_name} <#{request.rejected_by_authority.effective_contact_email}>"
    sent_on    Time.zone.now

    body       :request => request
  end


end

