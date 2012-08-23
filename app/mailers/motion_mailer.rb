class MotionMailer < ActionMailer::Base
  helper :application

  def propose_notice(motion)
    @motion = motion
    mail(
      to: motion.users.map(&:to_email),
      cc: motion.observer_emails,
      from: motion.effective_contact_name_and_email,
      subject: "#{motion.to_s :full} proposed"
    )
  end

  def restart_notice(motion)
    @motion = motion
    mail(
      to: motion.users.map(&:to_email),
      cc: motion.observer_emails,
      from: motion.effective_contact_name_and_email,
      subject: "#{motion.to_s :full} restarted"
    )
  end

  def withdraw_notice(motion)
    @motion = motion
    mail(
      to: motion.users.map(&:to_email),
      cc: motion.observer_emails,
      from: motion.effective_contact_name_and_email,
      subject: "#{motion.to_s :full} withdrawn"
    )
  end

  def divide_notice(motion)
    @motion = motion
    mail(
      to: motion.users.map(&:to_email),
      cc: motion.observer_emails,
      from: motion.effective_contact_name_and_email,
      subject: "#{motion.to_s :full} divided"
    )
  end

  def merge_notice(motion)
    @motion = motion
    mail(
      to: motion.users.map(&:to_email),
      cc: motion.observer_emails,
      from: motion.effective_contact_name_and_email,
      subject: "#{motion.to_s :full} merged"
    )
  end

  def reject_notice(motion)
    @motion = motion
    mail(
      to: motion.users.map(&:to_email),
      cc: motion.observer_emails,
      from: motion.effective_contact_name_and_email,
      subject: "#{motion.to_s :full} rejected"
    )
  end

  def adopt_notice(motion)
    @motion = motion
    mail(
      to: motion.users.map(&:to_email),
      cc: motion.observer_emails,
      from: motion.effective_contact_name_and_email,
      subject: "#{motion.to_s :full} adopted"
    )
  end

  def implement_notice(motion)
    @motion = motion
    mail(
      to: motion.users.map(&:to_email),
      cc: motion.observer_emails,
      from: motion.effective_contact_name_and_email,
      subject: "#{motion.to_s :full} implemented"
    )
  end

  def refer_notice(motion)
    @motion = motion
    mail(
      to: motion.users.map(&:to_email),
      cc: motion.observer_emails,
      from: motion.effective_contact_name_and_email,
      subject: "#{motion.to_s :full} referred to #{motion.referred_motions.first.committee}"
    )
  end

end

