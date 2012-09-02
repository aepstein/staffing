class Motion < ActiveRecord::Base
  include CommitteeNameLookup

  attr_accessible :period_id, :name, :content, :description, :complete,
    :referring_motion_id, :sponsorships_attributes, :attachments_attributes,
    as: [ :default, :divider, :referrer ]
  attr_accessible :referred_motions_attributes, as: [ :divider, :referrer ]
  attr_accessible :name, :committee_name, as: :referrer
  attr_readonly :committee_id, :period_id

  acts_as_list scope: [ :period_id, :committee_id ]

  belongs_to :period, inverse_of: :motions
  belongs_to :committee, inverse_of: :motions
  belongs_to :referring_motion, inverse_of: :referred_motions,
    class_name: 'Motion'

  has_many :sponsorships, inverse_of: :motion do
    # Build and return a sponsorship if provided user is allowed
    # Otherwise, return nil
    def populate_for( user )
      if proxy_association.owner.users.allowed.include? user
        p = build
        p.user = user
        return p
      end
    end
  end
  has_many :users, through: :sponsorships do
    # Only voting members may be sponsors
    def allowed
      return [] unless proxy_association.owner.committee && proxy_association.owner.period_id?
      User.joins(:memberships).merge(
        proxy_association.owner.committee.memberships.where( 'enrollments.votes > 0' ).
        overlap( proxy_association.owner.period.starts_at,
        proxy_association.owner.period.ends_at ).except(:order)
      )
    end
  end
  has_and_belongs_to_many :watchers, class_name: 'User',
    join_table: 'motions_watchers'
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :meeting_motions, dependent: :destroy
  has_many :meetings, through: :meeting_motions
  has_one :terminal_motion_merger, inverse_of: :merged_motion, dependent: :destroy,
    class_name: 'MotionMerger', foreign_key: :merged_motion_id
  has_one :terminal_merged_motion, through: :terminal_motion_merger,
    source: :motion
  has_many :motion_mergers, inverse_of: :motion, dependent: :destroy
  has_many :merged_motions, through: :motion_mergers, source: :merged_motion
  has_many :referred_motions, inverse_of: :referring_motion,
    class_name: 'Motion', foreign_key: :referring_motion_id,
    dependent: :destroy do
    def build_referee( referral_attributes = {} )
      referral_attributes ||= {}
      new_motion = build( proxy_association.owner.attributes )
      new_motion.assign_attributes referral_attributes, as: :referrer
      new_motion.period ||= new_motion.committee.periods.active if new_motion.committee
      new_motion
    end

    def build_divided( instances=false )
      instances ||= (empty? ? 2 : 1 )
      new_motions = []
      new_attributes = proxy_association.owner.attributes
      %w( committee_id id position created_at updated_at ).each { |attribute| new_attributes.delete attribute }
      instances.times do |i|
        new_attributes[:name] = "#{proxy_association.owner.name} (#{proxy_association.owner.id}-#{i})"
        new_motion = build new_attributes
        new_motion.committee = proxy_association.owner.committee
        new_motions << new_motion
      end
      new_motions
    end

    def create_divided!( instances=false )
      build_divided( instances ).map { |motion| motion.save!; motion }
    end
  end

  scope :ordered, order { position }
  scope :past, lambda { joins(:period).merge Period.unscoped.past }
  scope :current, lambda { joins(:period).merge Period.unscoped.current }
  scope :in_process, lambda { with_status( :started, :proposed ) }

  accepts_nested_attributes_for :attachments, allow_destroy: true
  accepts_nested_attributes_for :sponsorships, allow_destroy: true
  accepts_nested_attributes_for :referred_motions, allow_destroy: true

  delegate :periods, :period_ids, to: :committee

  validates :name, presence: true, uniqueness: {
    scope: [ :period_id, :committee_id ] }
  validates :position, uniqueness: { scope: [ :period_id, :committee_id ] }
  validates :period, presence: true
  validates :committee, presence: true
  validate :period_must_be_in_committee_schedule

#  before_validation :add_to_list_bottom, :on => :create
  before_create do |motion|
    if motion.referee?
      motion.referring_motion.lock!
      motion.referring_motion.refer!
    end
  end
  after_create do |motion|
    motion.referring_motion.save! if motion.referee?
  end

  state_machine :status, :initial => :started do

    before_transition all - :divided => :divided, :do => :do_divide
    before_transition all - :proposed => :proposed do |motion|
      motion.published = true
    end

    state :started, :proposed, :referred, :merged, :divided, :withdrawn, :adopted,
      :implemented, :cancelled

    event :propose do
      transition :started => :proposed
    end
    event :adopt do
      transition :proposed => :adopted
    end
    event :merge do
      transition :proposed => :merged
    end
    event :divide do
      transition :proposed => :divided
    end
    event :refer do
      transition [ :proposed, :adopted ] => :referred
    end
    event :implement do
      transition :adopted => :implemented
    end
    event :restart do
      transition :withdrawn => :started
    end
    event :reject do
      transition [ :proposed, :adopted ] => :rejected
    end
    event :withdraw do
      transition [ :started, :proposed ] => :withdrawn
    end

  end

  notifiable_events :propose

  # Users who should be notified of this motion's progress
  def observers
    ( watchers + committee.observers ).uniq
  end

  # Emails of observers OR default observer email if no observers are available
  def observer_emails
    observers.map(&:to_email) +
      Staffing::Application.app_config['defaults']['observer_email']
  end

  def tense
    return nil if period.blank?
    period.tense
  end

  # Motion has been referred from another committee
  def referee?
    return true if referring_motion && ( referring_motion.committee != committee )
    false
  end

  # Motion originates from a divided motion
  def divisee?
    return true if referring_motion && ( referring_motion.committee == committee )
    false
  end

  # What motions can this motion be merged to?
  def mergeable_motions
    committee.motions.with_status( :proposed ).where { |m| m.id.not_eq( id ) }
  end

  def to_s(format=nil)
    case format
    when :file
      to_s(:full).strip.downcase.gsub(/[^a-z0-9]/,'-').squeeze('-')
    when :full
      "#{committee} #{to_s :numbered}"
    when :numbered
      "R. #{position}: #{name}"
    else
      name
    end
  end

  protected

  def do_divide; referred_motions.create_divided!; end

  def period_must_be_in_committee_schedule
    return unless period && committee
    unless committee.schedule.periods.include? period
      errors.add :period, 'must be in schedule of committee'
    end
  end

end

