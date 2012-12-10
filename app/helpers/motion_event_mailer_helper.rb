module MotionEventMailerHelper
  def salutation
    "Dear #{recipients.map(&:first_name).listify},"
  end
end

