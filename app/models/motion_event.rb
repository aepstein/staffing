class MotionEvent < ActiveRecord::Base
  belongs_to :motion, inverse_of: :motion_events
  attr_accessible :description, :occurrence, :event
  attr_readonly :event

  validates :motion, presence: true
  validates :occurrence, presence: true
  validates :event, presence: true

  scope :ordered, lambda { order { [ occurrence, created_at ] } }
end

