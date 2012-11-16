class MembershipRequestMailer < ActionMailer::Base
  helper :application

  def reject_notice( membership_request )
    @membership_request = membership_request
    mail(
      to: membership_request.user.to_email,
      from: "\"#{membership_request.rejected_by_authority.effective_contact_name}\" " +
        "<#{membership_request.rejected_by_authority.effective_contact_email}>",
      subject: "Your request for appointment to #{membership_request.committee} was declined"
    )
  end

  def close_notice( membership_request )
    @membership_request = membership_request
    mail(
      to: membership_request.user.to_email,
      from: "\"#{Staffing::Application.app_config['defaults']['authority']['contact_name']}\" " +
        "<#{Staffing::Application.app_config['defaults']['authority']['contact_email']}>",
      subject: "Your request for appointment to #{membership_request.committee} was approved"
    )
  end
end

