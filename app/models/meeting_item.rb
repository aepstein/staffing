class MeetingItem < ActiveRecord::Base
  belongs_to :meeting_section, inverse_of: :meeting_items
  belongs_to :motion, inverse_of: :meeting_items
  attr_accessible :description, :duration, :name, :position

  acts_as_list scope: :meeting_section_id

  validates :meeting_section, presence: true
  validates :name, uniqueness: { scope: :meeting_section_id }, allow_blank: true
  validates :duration, presence: true, numericality: { integer_only: true, greater_than: 0 }
  validates :motion, inclusion: { in: lambda { |i| i.allowed_motions } }, allow_blank: true
  validates :motion_id, uniqueness: { scope: :meeting_section_id }, allow_blank: true
  validate :name_or_motion_must_be_present

  delegate :meeting, to: :meeting_section, allow_nil: true

  def allowed_motions
    return [] unless meeting
    meeting.motions.allowed
  end

  protected

  def name_or_motion_must_be_present
    errors.add :name, 'must be specified' unless name? || motion
    errors.add :name, 'cannot be specified if motion is associated' if name? && motion
  end
end

