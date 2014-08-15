class MotionEvent < ActiveRecord::Base
  NOTIFIABLE_EVENTS = %w( propose adopt reject refer implement divide merge restart )
  belongs_to :motion, inverse_of: :motion_events
  belongs_to :user, inverse_of: :motion_events
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :motion_votes, inverse_of: :motion_event, dependent: :delete_all do
    def populate
      return unless proxy_association.owner.occurrence
      ( proxy_association.owner.users - map(&:user) ).map do |user|
        build( user: user )
      end
    end
  end
  has_one :committee, through: :motion
  
  # These are memberships that have a vote
  # (relation is disabled as it no longer seems to work in rails > 4.0)
#  has_many :memberships, ->(e) { where( [ "enrollments.votes > 0 AND " +
#    "memberships.starts_at <= :e AND memberships.ends_at >= :e",
#    e: e.occurrence ] ).distinct }, through: :committee
  def memberships
    committee.memberships.where( [ "enrollments.votes > 0 AND " +
    "memberships.starts_at <= :e AND memberships.ends_at >= :e",
    e: occurrence ] ).distinct
  end

  # These are users that have a vote    
  # (relation is disabled as it no longer seems to work in rails > 4.0)
#  has_many :users, -> { distinct }, through: :memberships, source: :user
  def users
    User.where { |u| u.id.in( memberships.select { user_id } ) }
  end
  
  def user_ids
    users.value_of(:id)
  end
  
  attr_readonly :event

  accepts_nested_attributes_for :motion_votes, allow_destroy: true
  accepts_nested_attributes_for :attachments, allow_destroy: true
  
  validates :motion, presence: true
  validates :occurrence, presence: true, timeliness: {
    type: :date, on_or_after: :period_starts_at,
    on_or_before: -> { Time.zone.today }, if: :motion
  }
  validates :event, presence: true

  scope :ordered, -> { order { [ occurrence, created_at ] } }
  scope :occurred_since, ->(since) { where { occurrence.gte( since ) } }
  scope :notifiable, -> { where { event.in( MotionEvent::NOTIFIABLE_EVENTS ) } }
  scope :no_notice, -> { where { notice_sent_at.eq( nil ) } }
  scope :no_notice_since, ->(since) {
    where { notice_sent_at.eq( nil ) || notice_sent_at.lte( since ) }
  }

  delegate :period_starts_at, to: :motion
  
  before_validation do |event|
    event.attachments.select { |attachment| attachment.new_record? }.
      each do |attachment|
      attachment.attachable = event
    end
  end

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
  
  def to_s(format=nil)
    if motion
      "#{motion.to_s format}-#{event}"
    else
      super()
    end
  end
end

