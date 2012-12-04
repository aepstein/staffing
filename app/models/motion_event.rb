class MotionEvent < ActiveRecord::Base
  belongs_to :motion, inverse_of: :motion_events
  belongs_to :user, inverse_of: :motion_events
  attr_accessible :description, :occurrence, :event, :user
  attr_readonly :event

  validates :motion, presence: true
  validates :occurrence, presence: true
  validates :event, presence: true
  validates :user, presence: true
# TODO
#  validate do |motion_event|
#    if motion_event.occurrence && motion_event.meeting &&
#      motion_event.occurrence != motion_event.meeting.starts_at.to_date
#    end
#  end

  scope :ordered, lambda { order { [ occurrence, created_at ] } }
  scope :occurred_since, lambda { |since| where { occurrence.gte( since ) } }
  scope :no_notice, where { notice_sent_at.eq( nil ) }
  scope :no_notice_since, lambda { |since|
    where { notice_sent_at.eq( nil ) || notice_sent_at.lte( since ) }
  }

  def send_notice!
    MotionEventMailer.send( "#{event}_notice", self ).deliver
    self.update_attributes( { notice_sent_at: Time.zone.now },
      without_protection: true )
  end
end

