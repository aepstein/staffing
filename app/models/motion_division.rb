class MotionDivision < ActiveRecord::Base
  belongs_to :divided_motion
  belongs_to :motion
end
