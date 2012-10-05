class MotionEvent < ActiveRecord::Base
  belongs_to :motion, inverse_of: :motion_events
  attr_accessible :description, :effective_on, :event
  attr_readonly :event

  validates :motion, presence: true
  validates :effective_on, presence: true
  validates :event, presence: true, inclusion: {
    if: :motion, in: lambda { |event| event.motion.state_events.map(&:to_s) }
  }
end

