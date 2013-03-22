class Motion < ActiveRecord::Base
  include CommitteeNameLookup

  EVENTS = [ :adopt, :amend, :divide, :implement, :merge, :propose, :refer,
    :reject, :restart, :withdraw ]
  EVENTS_PUTONLY = [ :restart, :unwatch, :watch ]

  has_paper_trail
  has_ancestry

  attr_accessible :name, :content, :description, :complete,
    :referring_motion_id, :sponsorships_attributes, :attachments_attributes,
    :event_date, :event_description,
    as: [ :admin, :default, :divider, :referrer, :amender ]
  attr_accessible :event_date, :event_description, as: [ :eventor, :merger ]
  attr_accessible :period_id, as: [ :admin ]
  attr_accessible :referring_motion_attributes, as: [ :referrer ]
  attr_accessible :referred_motions_attributes, as: [ :divider ]
  attr_accessible :committee_name, as: :referrer
  attr_accessible :motion_meeting_segments, as: [ :admin, :default, :amender ]
  attr_readonly :committee_id, :period_id, :position

  belongs_to :period, inverse_of: :motions
  belongs_to :committee, inverse_of: :motions
  belongs_to :referring_motion, inverse_of: :referred_motions,
    class_name: 'Motion'
  belongs_to :meeting, inverse_of: :minute_motions

  has_many :peers, through: :committee, source: :motions,
    conditions: Proc.new { { period_id: period_id } }
  has_many :meeting_items, inverse_of: :motion, dependent: :destroy
  has_many :sponsorships, inverse_of: :motion, dependent: :destroy do
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
  has_many :meeting_items, dependent: :destroy, inverse_of: :motion
  has_many :meetings, through: :meeting_items
  has_many :motion_events, dependent: :destroy, inverse_of: :motion
  has_one :terminal_motion_merger, inverse_of: :merged_motion, dependent: :destroy,
    class_name: 'MotionMerger', foreign_key: :merged_motion_id
  has_one :terminal_merged_motion, through: :terminal_motion_merger,
    source: :motion
  has_many :motion_mergers, inverse_of: :motion, dependent: :destroy
  has_many :merged_motions, through: :motion_mergers, source: :merged_motion
  has_many :referred_motions, inverse_of: :referring_motion,
    class_name: 'Motion', foreign_key: :referring_motion_id,
    dependent: :restrict do
    def build_referee( referral_attributes = {} )
      referral_attributes ||= {}
      build( proxy_association.owner.attributes ) do |new_motion|
        new_motion.assign_attributes referral_attributes, as: :referrer
        new_motion.period ||= new_motion.committee.periods.active if new_motion.committee
      end
    end

    def build_amendment( amendment_attributes = {} )
      proxy_association.owner.amendment = build( proxy_association.owner.attributes ) do |new_motion|
        new_motion.assign_attributes amendment_attributes, as: :amender
        new_motion.meeting = proxy_association.owner.meeting
        new_motion.committee = proxy_association.owner.committee
        new_motion.period = proxy_association.owner.period
        new_motion.name = proxy_association.owner.amendable_name
      end
    end

    def prepare_divided
      each do |motion|
        next unless motion.new_record?
        motion.committee = @motion.committee
        motion.published = true
        motion.period = @motion.period
      end
    end
  end
  has_many :motion_meeting_segments, dependent: :destroy, inverse_of: :motion do
    def populate
      if referring_motion
        populate_from_motion referring_motion
      else
        proxy_association.owner.meeting.meeting_items.each do |item|
          build( description: item.name )
        end
      end
    end
    def populate_from_motion( motion )
      motion.motion_meeting_segments.each do |segment|
        build( segment.attributes, as: :amender )
      end
    end
    def comparable_attributes
      map do |segment|
        [ segment.position, segment.description, segment.meeting_item_id, segment.content ]
      end
    end
    def amend_from_motion( source )
      if source.motion_meeting_segments.comparable_attributes != comparable_attributes
        clear
        populate_from_motion( source )
      end
    end
  end

  scope :ordered, order { position }
  scope :past, lambda { joins(:period).merge Period.unscoped.past }
  scope :current, lambda { joins(:period).merge Period.unscoped.current }
  scope :in_process, lambda { with_status( :started, :proposed ) }

  accepts_nested_attributes_for :attachments, allow_destroy: true
  accepts_nested_attributes_for :sponsorships, allow_destroy: true
  accepts_nested_attributes_for :referred_motions
  accepts_nested_attributes_for :motion_meeting_segments, allow_destroy: true

  delegate :periods, :period_ids, to: :committee

  validates :name, presence: true, uniqueness: {
    scope: [ :period_id, :committee_id ] }
  validates :period, presence: true, inclusion: { if: :committee,
    in: lambda { |motion| motion.committee.schedule.periods } }
  validates :committee, presence: true
  validates :event_date, timeliness: { allow_blank: true, if: :period, type: :date,
    on_or_after: :period_starts_at, on_or_before: lambda { Time.zone.today } }
  # No validation on position -- this will be handled automatically

  before_create do |motion|
    if motion.referring_motion != motion.parent
      motion.parent = motion.referring_motion
    end
    if motion.referring_motion && motion.referring_motion.published?
      motion.published = true
    end
    motion.peers.lock
    motion.position = motion.peers.scoped.reset.count + 1
  end
  # Lock the list of motions for the period during destroy
  before_destroy do |motion|
    motion.peers.lock
    motion.position = Motion.scoped.reset.where { |m| m.id.eq( motion.id ) }.
      value_of(:position).first
  end
  # After destroy reposition subsequent items accordingly
  after_destroy do |motion|
    motion.peers.scoped.reset.where { |m| m.position.gt( motion.position ) }.
      update_all( "position = position - 1" )
  end

  state_machine :status, initial: :started do

    before_transition all => [ :divided, :referred, :amended ] do |motion, transition|
      motion.referred_motions.select(&:new_record?).each do |new_motion|
        new_motion.watchers << motion.watchers
      end
    end
    before_transition all - :proposed => :proposed do |motion|
      motion.published = true
    end
    before_transition :proposed => [ :implemented ] do |motion|
      if motion.referring_motion.amended?
        motion.referring_motion.amendment = motion
        motion.referring_motion.event_date = motion.event_date
        motion.referring_motion.event_description = motion.event_description
        motion.referring_motion.motion_meeting_segments.amend_from_motion( motion )
        motion.referring_motion.amend!
      end
    end
    before_transition :proposed => [ :rejected, :withdrawn ] do |motion|
      if motion.referring_motion && motion.referring_motion.amended?
        motion.referring_motion.unamend!
      end
    end
    before_transition :proposed => :amended do |motion|
      motion.amendment.propose!
    end
    before_transition :amended => :proposed do |motion|
      motion.description = motion.amendment.description
      motion.content = motion.amendment.content
      # TODO copy attachments from amendment
    end
    after_transition all => [ :started, :proposed, :referred, :merged, :divided,
      :withdrawn, :adopted, :implemented, :rejected ] do |motion, transition|
      motion.motion_events.create!(
        event: transition.event.to_s,
        description: motion.event_description,
        occurrence: motion.event_date.blank? ? Time.zone.today : motion.event_date
      )
    end
    after_transition all => [ :merged ] do |motion|
      motion.terminal_merged_motion.watchers << motion.watchers
    end

    state :proposed, :referred, :merged, :divided, :withdrawn, :adopted,
      :implemented, :rejected

    state :started do
      validate do |motion|
#        unless motion.referring_motion_id? || motion.sponsorships.reject(&:marked_for_destruction?).length > 0
#          errors.add :sponsorships, "cannot be empty for new motion"
#        end
      end
    end
    state :amended do
      validates :amendment, presence: true
    end

    event :propose do
      transition :started => :proposed
    end
    event :adopt do
      transition :proposed => :implemented, if: lambda { |m| m.referring_motion && m.referring_motion.amended? }
      transition :proposed => :adopted
    end
    event :amend do
      transition :proposed => :amended
      transition :amended => :proposed
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
      transition [ :proposed, :withdrawn ] => :started
    end
    event :reject do
      transition [ :proposed, :adopted ] => :rejected
    end
    event :unamend do
      transition :amended => :proposed
    end
    event :withdraw do
      transition [ :started, :proposed ] => :withdrawn
    end

  end

  notifiable_events :propose

  attr_accessor :event_description, :amendment
  attr_reader :event_date

  delegate :effective_contact_name_and_email, :effective_contact_email,
    :effective_contact_name, to: :committee

  def sponsored?; sponsorships.any?; end

  def event_date=(date)
    @event_date = if date.is_a?(String)
      d = Time.zone.parse(date)
      d.blank? ? d : d.to_date
    else
      date
    end
  end

  def period_starts_at
    return nil unless period
    period.starts_at
  end

  # Populate the event date with
  # * most meeting when scheduled, if any
  # * most recent past meeting occurring same period, if any
  # * today if period is current
  # TODO - behavior depends on the action:
  # * some actions don't require meetings so meeting-based default doesn't make
  #   sense
  def populate_event_date
    # TODO
  end

  def users_for( population, options = {} )
    include_referrers = options.delete :include_referrers || false
    users = case population
    when :sponsors
      self.users
    when :watchers
      committee.watchers
    when :monitors
      User.where { |u| u.id.in( committee.memberships.current.with_roles('monitor').select { user_id } ) }
    when :vicechairs
      User.where { |u| u.id.in( committee.memberships.current.with_roles('vicechair').select { user_id } ) }
    when :chairs
      User.where { |u| u.id.in( committee.memberships.current.with_roles('chair').select { user_id } ) }
    end
    if referring_motion && include_referrers
      users += referring_motion.users_for( population, include_referrers: include_referrers )
    end
    users.uniq
  end

  def emails_for( population, options = { include_referrers: false } )
    users_for( population, options ).map(&:email)
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

  # What motions can this motion be merged to?
  # * must be in same committee
  # * must be in proposed state
  # * must not be same motion
  # * must be in same period
  def mergeable_motions
    committee.motions.with_status( :proposed ).where { |m| m.id.not_eq( id ) }.
      where { |m| m.period_id.eq( period_id ) }
  end

  # Returns unique amendment name for the motion
  def amendable_name
    candidate = "Amend #{name} #1"
    while committee.motions.where { |m| m.period_id.eq( period_id ) && m.name.eq( candidate ) }.exists? do
      candidate.gsub!( /#(\d+)$/ ) { "##{$1.to_i + 1}" }
    end
    candidate
  end

  def populate_from_meeting
    return unless meeting
    self.name ||= "Minutes of #{proxy_association.owner.starts_at.to_s :long}"
    self.description ||= "Adopt minutes of #{proxy_association.owner}"
    self.content ||= "RESOLVED the minutes of #{proxy_association.owner} are adopted as provided below."
    motion_meeting_segments.populate
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
      name? ? name : super()
    end
  end

  protected

  def period_must_be_in_committee_schedule
    return unless period && committee
    unless committee.schedule.periods.include? period
      errors.add :period, 'must be in schedule of committee'
    end
  end

end

