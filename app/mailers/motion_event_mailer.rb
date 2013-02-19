class MotionEventMailer < ActionMailer::Base
  helper :application
  helper_method :vicechairs, :chairs, :sponsors, :motion, :event, :recipients
  attr_accessor :motion, :event, :recipients

  def event_notice(e)
    initialize_context e
    send "#{e.event}_notice"
  end

  def propose_notice
    self.recipients = vicechairs
    mail(
      to: recipients.map(&:email),
      cc: sponsors.map(&:email),
      from: motion.effective_contact_email,
      subject: "#{motion.to_s :full} proposed",
      template_name: 'propose_notice'
    )
  end

  def restart_notice
    self.recipients = sponsors
    mail(
      to: recipients.map(&:email),
      cc: vicechairs.map(&:email),
      from: motion.effective_contact_email,
      subject: "#{motion.to_s :full} restarted",
      template_name: 'restart_notice'
    )
  end

  def withdraw_notice
    self.recipients = sponsors
    mail(
      to: recipients.map(&:email),
      cc: vicechairs.map(&:email),
      from: motion.effective_contact_email,
      subject: "#{motion.to_s :full} withdrawn",
      template_name: 'withdraw_notice'
    )
  end

  def reject_notice
    self.recipients = sponsors
    mail(
      to: recipients.map(&:email),
      cc: vicechairs.map(&:email),
      from: motion.effective_contact_email,
      subject: "#{motion.to_s :full} rejected",
      template_name: 'reject_notice'
    )
  end

  def amend_notice
    self.recipients = vicechairs
    mail(
      to: recipients.map(&:email),
      cc: sponsors.map(&:email),
      from: motion.effective_contact_email,
      subject: "#{motion.to_s :full} amended",
      template_name: 'amend_notice'
    )
  end

  def divide_notice
    self.recipients = vicechairs
    mail(
      to: recipients.map(&:email),
      cc: sponsors.map(&:email),
      from: motion.effective_contact_name_and_email,
      subject: "#{motion.to_s :full} divided",
      template_name: 'divide_notice'
    )
  end

  def merge_notice
    self.recipients = vicechairs
    mail(
      to: recipients.map(&:email),
      cc: sponsors.map(&:email),
      from: motion.effective_contact_name_and_email,
      subject: "#{motion.to_s :full} merged",
      template_name: 'merge_notice'
    )
  end

  def adopt_notice
    self.recipients = chairs
    mail(
      to: recipients.map(&:email),
      cc: sponsors.map(&:email),
      from: motion.effective_contact_name_and_email,
      subject: "#{motion.to_s :full} adopted",
      template_name: 'adopt_notice'
    )
  end

  def implement_notice
    self.recipients = chairs
    mail(
      to: recipients.map(&:email),
      cc: sponsors.map(&:email),
      from: motion.effective_contact_name_and_email,
      subject: "#{motion.to_s :full} implemented",
      template_name: 'implement_notice'
    )
  end

  def refer_notice
    mail(
      to: motion.users.map(&:to_email),
      cc: motion.observer_emails,
      from: motion.effective_contact_name_and_email,
      subject: "#{motion.to_s :full} referred to #{motion.referred_motions.first.committee}"
    )
  end

  protected

  def sponsors
    @sponsors ||= motion.users_for(:sponsors, include_referrers: true)
  end

  def vicechairs
    return @vicechairs if @vicechairs
    @vicechairs = motion.users_for(:vicechairs)
    return @vicechairs if @vicechairs.length > 0
    @vicechairs = chairs
  end

  def chairs
    @chairs ||= motion.users_for(:chairs)
  end

  def initialize_context(e)
    self.event = e
    self.motion = e.motion
  end

end

