class MotionMeetingSegment < ActiveRecord::Base
  belongs_to :motion, inverse_of: :motion_meeting_segments
  belongs_to :meeting_item, inverse_of: :motion_meeting_segments
  attr_readonly :motion_id

  validates :position, numericality: { integer_only: true, greater_than: 0 },
    presence: true
  validates :minutes_from_start, numericality: { integer_only: true,
    greater_than: 0 }, allow_blank: true

  scope :ordered, -> { order { motion_meeting_segments.position } }

  def to_s
    if meeting_item
      meeting_item.to_s
    elsif new_record?
      "New Meeting Segment"
    elsif description
      description
    else
      super
    end
  end
end

