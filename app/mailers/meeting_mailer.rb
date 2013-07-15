class MeetingMailer < ActionMailer::Base
  attr_accessor :meeting, :note
  helper_method :clerks, :meeting, :note, :linked_attachments
  helper MeetingsHelper

  THRESHOLD = 2.megabytes

  def publish_notice( meeting, options = {})
    self.meeting = meeting
    self.note = options.delete :note
    to = options.delete :to
    from = options.delete :from
    add_attachments
    mail( to: to, from: from,
      subject: "#{meeting.committee} Meeting on #{meeting.starts_at.to_date.to_s :long_ordinal}" )
  end

  def minutes_notice( meeting, options = {})
    self.meeting = meeting
    mail( to: clerks.map(&:to_email), from: meeting.effective_contact_name_and_email,
      subject: "Minutes Needed for #{meeting.committee} meeting on #{meeting.starts_at.to_date.to_s :long_ordinal}" )
  end

  def overdue_minutes_notice( meeting, options = {})
    self.meeting = meeting
    mail( to: clerks.map(&:to_email), cc: vicechairs,
      from: meeting.effective_contact_name_and_email,
      subject: "Minutes Overdue for #{meeting.committee} meeting on #{meeting.starts_at.to_date.to_s :long_ordinal}" )
  end

  def clerks
    @clerks ||= meeting.users_for(:clerks)
  end

  def vicechairs
    @vicechairs ||= meeting.users_for(:vicechairs)
  end

  def add_attachments
    enclosures = meeting.attachments.values.flatten.
      reject { |attachment| linked_attachments.include?(attachment) }
    enclosures.each do |attachment|
      if attachment.instance_of?( Motion )
        attachments[meeting.attachment_filename(attachment)] = MotionReport.new( attachment ).to_pdf
      elsif attachment.instance_of?( MotionCommentReport )
        attachments[meeting.attachment_filename(attachment)] = attachment.to_pdf
      else
        attachments[meeting.attachment_filename(attachment)] = attachment.document.read
      end
    end
  end

  # Returns list of enclosures that should be linked rather than attached
  # Assures attachments do not exceed a specified threshold size
  def linked_attachments
    @linked_attachments ||= []
    meeting.attachments.values.flatten.
      reject { |attachment| attachment.instance_of?( Motion ) || attachment.instance_of?( MotionCommentReport ) }.
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

