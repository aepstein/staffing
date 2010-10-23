class MotionMerger < ActiveRecord::Base
  belongs_to :merged_motion, :class_name => 'Motion'
  belongs_to :motion

  validates_presence_of :merged_motion
  validates_presence_of :motion

  before_create do |merger|
    merger.merged_motion.lock!
    merger.merged_motion.merge!
  end

  after_create do |merger|
    merger.merged_motion.save!
  end

end

