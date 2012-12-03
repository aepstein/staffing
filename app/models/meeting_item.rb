class MeetingItem < ActiveRecord::Base
  belongs_to :meeting_section, inverse_of: :meeting_items
  has_one :meeting, through: :meeting_section
  belongs_to :motion, inverse_of: :meeting_items
  attr_accessible :description, :duration, :name, :position, :motion_name,
    :_destroy

  default_scope order { [ meeting_section_id, position ] }

  validates :meeting_section, presence: true
  validates :name, uniqueness: { scope: :meeting_section_id }, allow_blank: true
  validates :duration, presence: true, numericality: { integer_only: true, greater_than: 0 }
  validates :motion, inclusion: { in: lambda { |i| i.allowed_motions } }, allow_blank: true
  validates :motion_id, uniqueness: { scope: :meeting_section_id }, allow_blank: true
  validate :name_or_motion_must_be_present

  before_validation do |item|
    item.name = nil if item.name.blank?
  end

  delegate :meeting, to: :meeting_section, allow_nil: true

  def allowed_motions
    return [] unless meeting
    meeting.motions.allowed
  end

  def motion_name=(n)
    return nil unless meeting
    self.motion = meeting.motions.allowed.find_by_name( n )
    n
  end

  def motion_name
    return nil unless motion
    motion.name
  end

  protected

  def name_or_motion_must_be_present
    errors.add :name, 'must be specified' unless name? || motion
    errors.add :name, 'cannot be specified if motion is associated' if name? && motion
  end
end

