class MotionMerger < ActiveRecord::Base
  attr_accessible :merged_motion_id, :motion_id
  attr_readonly :merged_motion_id, :motion_id

  belongs_to :merged_motion, class_name: 'Motion', inverse_of: :terminal_motion_merger
  belongs_to :motion, inverse_of: :motion_mergers

  validates :merged_motion, presence: true, on: :create
  validates :merged_motion_id, uniqueness: true, on: :create
  validates :motion, presence: true, on: :create, inclusion: {
    if: :merged_motion,
    in: lambda { |merger| merger.merged_motion.mergeable_motions }
  }
  validate :merged_motion_must_be_mergeable, on: :create

  before_create do |merger|
    merger.merged_motion.lock!
  end

  after_create do |merger|
    merger.merged_motion.merge!
  end

  protected

  def merged_motion_must_be_mergeable
    return unless motion && merged_motion
    errors.add :merged_motion, "must be mergeable" unless merged_motion.can_merge?
  end

end

