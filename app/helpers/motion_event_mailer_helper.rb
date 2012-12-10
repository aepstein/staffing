module MotionEventMailerHelper
  def salutation
    "Dear #{recipients.map(&:first_name).listify},"
  end

  def referred_motion_description( motion )
    if motion.referring_motion.committee == motion.committee
      if motion.referring_motion.status == 'divided'
        "a successor of divided #{motion.referring_motion.to_s :numbered}"
      # TODO a motion that is amended, then divided might be miscategorized under this test
      else
        "an amendment of #{motion.referring_motion.to_s :numbered}"
      end
    else
      "a referral of #{motion.referring_motion.to_s :full}"
    end
  end
end

