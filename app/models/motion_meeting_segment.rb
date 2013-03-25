class MotionMeetingSegment < ActiveRecord::Base
  belongs_to :motion, inverse_of: :motion_meeting_segments
  belongs_to :meeting_item, inverse_of: :motion_meeting_segments
  attr_accessible :position, :content, :description, :minutes_from_start,
    :meeting_item_id, as: [ :admin, :default, :amender ]
  attr_readonly :motion_id

  validates :position, numericality: { integer_only: true, greater_than: 0 },
    presence: true
  validates :minutes_from_start, numericality: { integer_only: true,
    greater_than: 0 }, allow_blank: true

  scope :ordered, lambda { order { position } }

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

