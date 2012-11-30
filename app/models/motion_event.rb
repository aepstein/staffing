class MotionEvent < ActiveRecord::Base
  belongs_to :motion, inverse_of: :motion_events
  attr_accessible :description, :occurrence, :event
  attr_readonly :event

  validates :motion, presence: true
  validates :occurrence, presence: true
  validates :event, presence: true
# TODO
#  validate do |motion_event|
#    if motion_event.occurrence && motion_event.meeting &&
#      motion_event.occurrence != motion_event.meeting.starts_at.to_date
#    end
#  end

  scope :ordered, lambda { order { [ occurrence, created_at ] } }
end

