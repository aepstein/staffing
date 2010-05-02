class RequestMailer < ActionMailer::Base
  

  def create_notice(sent_at = Time.now)
    subject    'RequestMailer#create_notice'
    recipients ''
    from       ''
    sent_on    sent_at
    
    body       :greeting => 'Hi,'
  end

end
