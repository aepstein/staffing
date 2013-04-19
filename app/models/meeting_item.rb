class MeetingItem < ActiveRecord::Base
  belongs_to :meeting_section, inverse_of: :meeting_items
  belongs_to :motion, inverse_of: :meeting_items
  has_many :motion_meeting_segments, inverse_of: :meeting_item, dependent: :nullify
  has_many :attachments, as: :attachable, dependent: :destroy
  attr_accessible :description, :duration, :name, :position, :motion_id,
    :motion_name, :_destroy, :attachments_attributes, :named,
    as: [ :default, :staff ]
  attr_readonly :motion_id

  attr_accessor :named

  default_scope order { [ meeting_section_id, position ] }

  validates :meeting_section, presence: true
  validates :name, uniqueness: { scope: :meeting_section_id }, allow_blank: true
  validates :duration, presence: true, numericality: { integer_only: true, greater_than: 0 }
  validates :motion, inclusion: { in: lambda { |i| i.allowed_motions } }, allow_blank: true
  validates :motion_id, uniqueness: { scope: :meeting_section_id }, allow_blank: true
  validate :name_or_motion_must_be_present

  accepts_nested_attributes_for :attachments, allow_destroy: true

  before_validation do |item|
    item.name = nil if item.name.blank?
  end

  def meeting
    ActiveSupport::Deprecation.warn( "meeting() is deprecated and may be removed " +
      "from future releases, use meeting_section.meeting() instead.", caller )
    meeting_section.meeting
  end

  def allowed_motions
    return [] unless meeting_section && meeting_section.meeting
    meeting_section.meeting.motions.allowed
  end

  def enclosures
    return [ motion ] + motion.attachments.to_a if motion
    attachments
  end

  # Accepts motion optionally prefixed with R. #:
  def motion_name=(n)
    self.motion = meeting_section.meeting.committee.motions.find_by_name(
      n.slice( /^(?:R\. \d+\: )?(.*)/, 1 ) )
    n
  end

  def motion_name
    return nil unless motion
    motion.to_s(:numbered)
  end

  def display_name
    motion ? motion.to_s(:numbered) : name
  end

  def to_s(format = nil)
    case format
    when :file
      to_s.strip.downcase.gsub(/[^a-z0-9]/,'-').squeeze('-')
    else
      new_record? ? "New Meeting Item" : display_name
    end
  end

  protected

  def name_or_motion_must_be_present
    errors.add :name, 'must be specified' unless name? || motion
    errors.add :name, 'cannot be specified if motion is associated' if name? && motion
  end

  def attachments_not_allowed_with_motion
    errors.add :attachments, 'are not allowed with a motion item' if motion && attachments.length > 0
  end
end

