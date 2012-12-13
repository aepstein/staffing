class MeetingMailer < ActionMailer::Base
  attr_accessor :meeting
  helper_method :meeting, :linked_attachments
  helper MeetingsHelper

  THRESHOLD = 2.megabytes

  def publish_notice( meeting, options = {})
    self.meeting = meeting
    to = options.delete :to
    from = options.delete :from
    mail( to: to, from: from,
      subject: "#{meeting.committee} Meeting on #{meeting.starts_at.to_date.to_s :long_ordinal}" )
    add_attachments
  end

  def add_attachments
    enclosures = meeting.attachments.values.flatten.
      reject { |attachment| linked_attachments.include?(attachment) }
    enclosures.each do |attachment|
      attachments[meeting.attachment_filename(attachment)] = attachment.document.read
    end
  end

  # Returns list of enclosures that should be linked rather than attached
  # Assures attachments do not exceed a specified threshold size
  def linked_attachments
    @linked_attachments ||= []
    meeting.attachments.values.flatten.
      sort { |x,y| x.document.size <=> y.document.size }.
      reduce(0) do |size, attachment|
      if ( size + attachment.document.size ) > THRESHOLD
        @linked_attachments.push attachment
        size
      else
        size + attachment.document.size
      end
    end
    @linked_attachments
  end
end

