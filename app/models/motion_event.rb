class MotionEvent < ActiveRecord::Base
  NOTIFIABLE_EVENTS = %w( propose adopt reject refer implement divide merge restart )
  belongs_to :motion, inverse_of: :motion_events
  belongs_to :user, inverse_of: :motion_events
  has_many :motion_votes, inverse_of: :motion_event, dependent: :delete_all
  has_one :committee, through: :motion
  # These are memberships that have a vote
  has_many :memberships, through: :committee, uniq: true,
    conditions: Proc.new {  [ "enrollments.votes > 0 AND " +
      "memberships.starts_at <= :e AND memberships.ends_at >= :e",
      e: occurrence ] }
  has_many :users, through: :memberships, uniq: true
  attr_accessible :description, :occurrence, :event, :user
  attr_readonly :event

  validates :motion, presence: true
  validates :occurrence, presence: true, timeliness: {
    type: :date, on_or_after: :period_starts_at,
    on_or_before: lambda { Time.zone.today }, if: :motion
  }
  validates :event, presence: true
# TODO
#  validate do |motion_event|
#    if motion_event.occurrence && motion_event.meeting &&
#      motion_event.occurrence != motion_event.meeting.starts_at.to_date
#    end
#  end

  scope :ordered, lambda { order { [ occurrence, created_at ] } }
  scope :occurred_since, lambda { |since| where { occurrence.gte( since ) } }
  scope :notifiable, lambda { where { event.in( MotionEvent::NOTIFIABLE_EVENTS ) } }
  scope :no_notice, where { notice_sent_at.eq( nil ) }
  scope :no_notice_since, lambda { |since|
    where { notice_sent_at.eq( nil ) || notice_sent_at.lte( since ) }
  }

  delegate :period_starts_at, to: :motion
  
  # Vote tally for particular type of vote
  def votes(type)
    send("unrecorded_#{type}_votes") + motion_votes.of_type(type).count
  end

  def send_notice!
    message = MotionEventMailer.event_notice self
    if message.to.present?
      message.deliver
      self.update_attributes( { notice_sent_at: Time.zone.now },
        without_protection: true )
    end
  end
end

