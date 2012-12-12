class MeetingMailer < ActionMailer::Base
  attr_accessor :meeting
  helper_method :meeting

  def publish_notice( meeting, from, to )
    self.meeting = meeting
    mail( to: to, from: from,
      subject: "Notice regarding #{meeting.starts_at.to_date.to_s :rfc822} #{meeting.committee} meeting" )
  end
end

