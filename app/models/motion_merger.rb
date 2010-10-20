class MotionMerger < ActiveRecord::Base
  belongs_to :merged_motion
  belongs_to :motion
end
