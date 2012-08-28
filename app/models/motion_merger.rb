class MotionMerger < ActiveRecord::Base
  attr_accessible :merged_motion_id, :motion_id

  belongs_to :merged_motion, class_name: 'Motion', inverse_of: :terminal_motion_merger
  belongs_to :motion, inverse_of: :motion_mergers

  validates :merged_motion, presence: true
  validates :merged_motion_id, uniqueness: true
  validates :motion, presence: true

  before_create do |merger|
    merger.merged_motion.lock!
    merger.merged_motion.merge!
  end

  after_create do |merger|
    merger.merged_motion.save!
  end

end

