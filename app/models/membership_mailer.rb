class MembershipMailer < ActionMailer::Base
  

  def join_notice(sent_at = Time.now)
    subject    'MembershipMailer#join_notice'
    recipients ''
    from       ''
    sent_on    sent_at
    
    body       :greeting => 'Hi,'
  end

  def leave_notice(sent_at = Time.now)
    subject    'MembershipMailer#leave_notice'
    recipients ''
    from       ''
    sent_on    sent_at
    
    body       :greeting => 'Hi,'
  end

end
