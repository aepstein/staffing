class MotionMerger < ActiveRecord::Base
  belongs_to :merged_motion
  belongs_to :motion

  before_save do |merger|
    merger.merged_motion.lock!
    merger.merged_motion.merge!
  end

  after_save do |merger|
    merger.merged_motion.save!
  end

end

