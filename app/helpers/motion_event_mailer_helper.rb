module MotionEventMailerHelper
  def salutation
    "Dear #{vicechairs.map(&:first_name).listify},"
  end
end

