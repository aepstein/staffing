class Motion < ActiveRecord::Base
  include CommitteeNameLookup

  EVENTS = [ :adopt, :amend, :divide, :implement, :merge, :propose, :refer,
    :reject, :restart, :withdraw ]
  EVENTS_PUTONLY = [ :restart, :unwatch, :watch ]
  
  def self.permitted_attributes(type)
    case type
    when :default
      [ :id, :name, :content, :description, :complete,
        { motion_meeting_segments_attributes: [ :id, :_destroy, :position,
            :content, :description, :minutes_from_start, :meeting_item_id ],
          sponsorships_attributes: Sponsorship::PERMITTED_ATTRIBUTES,
          attachments_attributes: Attachment::PERMITTED_ATTRIBUTES } ]
    when :admin
      permitted_attributes( :default ) + [ :period_id, :comment_until ]
    else
      []
    end
  end

  has_paper_trail
  has_ancestry

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
    def path
      Sponsorship.where { |s| s.motion_id.in( proxy_association.owner.path.select { id } ) }
    end
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
  has_many :motion_events, dependent: :destroy, inverse_of: :motion do
    def populate_for( event )
      e = if i = index { |e| e.new_record? }
        self[i]
      else
        build
      end
      e.event ||= event
      e.occurrence ||= Time.zone.today
      e
    end
    
    def subsidiary_event( event_name, event )
      subsidiary_event = populate_for event_name
      subsidiary_event.assign_attributes occurrence: event.occurrence,
        description: event.description
      proxy_association.owner.send "#{event_name}!"
    end
    
    def propose_from( event )
      subsidiary_event 'propose', event
    end
  end
  has_one :terminal_motion_merger, inverse_of: :merged_motion, dependent: :destroy,
    class_name: 'MotionMerger', foreign_key: :merged_motion_id
  has_one :terminal_merged_motion, through: :terminal_motion_merger,
    source: :motion
  has_many :motion_mergers, inverse_of: :motion, dependent: :destroy
  has_many :merged_motions, through: :motion_mergers, source: :merged_motion
  has_many :referred_motions, inverse_of: :referring_motion,
    class_name: 'Motion', foreign_key: :referring_motion_id,
    dependent: :restrict do
    def populate_single
      motion = if i = index { |m| m.new_record? }
        self[i]
      else
        build
      end
    end
    
    def pending
      select { |m| m.new_record? }
    end
    
    def initialize_contents_from_referring_motion(motion)
      motion.description = proxy_association.owner.description
      motion.content = proxy_association.owner.content
      #TODO copy attachments
      #TODO copy meeting segments or disallow referral of minutes motion
      motion
    end
    
    def populate_referee
      motion = populate_single
      initialize_contents_from_referring_motion motion
    end
    
    def populate_amendment(initialize_contents=false)
      motion = populate_single
      source_attributes = proxy_association.owner.attributes
      motion.assign_attributes meeting: proxy_association.owner.meeting,
        committee: proxy_association.owner.committee,
        period: proxy_association.owner.period,
        name: proxy_association.owner.amendable_name
      initialize_contents_from_referring_motion motion if initialize_contents
      motion
    end

    def prepare_divided
      each do |motion|
        next unless motion.new_record?
        motion.committee = proxy_association.owner.committee
        motion.published = true
        motion.period = proxy_association.owner.period
      end
    end
  end
  has_many :motion_meeting_segments, dependent: :destroy, inverse_of: :motion do
    def populate
      if proxy_association.owner.referring_motion
        populate_from_motion proxy_association.owner.referring_motion
      else
        i = 0
        proxy_association.owner.meeting.meeting_items.each do |item|
          i +=  1
          build( position: i ) do |segment|
            segment.meeting_item = item
          end
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
  has_many :motion_comments, inverse_of: :motion, dependent: :destroy

  scope :ordered, order { position }
  scope :past, lambda { joins(:period).merge Period.unscoped.past }
  scope :current, lambda { joins(:period).merge Period.unscoped.current }
  scope :in_process, lambda { with_status( :started, :proposed ) }

  accepts_nested_attributes_for :motion_events, allow_destroy: true
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
    around_transition all => [ :referred ] do |motion, transition, block|
      event = motion.motion_events.populate_for( 'refer' )
      referee = motion.referred_motions.populate_referee
      if event.occurrence && referee.committee
        referee.period = referee.committee.schedule.periods.
          overlaps( event.occurrence, event.occurrence ).first
      end
      block.call
      referee.motion_events.propose_from event
    end
    before_transition all - :proposed => :proposed do |motion|
      motion.published = true
    end
    around_transition :proposed => [ :rejected, :withdrawn ] do |motion, transition, block|
      if motion.referring_motion && motion.referring_motion.amended?
        reject_event = motion.motion_events.populate_for transition.event.to_s
        amended = motion.referring_motion
        block.call
        amended.motion_events.subsidiary_event 'unamend', reject_event
      else
        block.call
      end
    end
    around_transition :proposed => :divided do |motion, transition, block|
      divide_event = motion.motion_events.populate_for transition.event.to_s
      motion.referred_motions.prepare_divided
      divisions = motion.referred_motions.pending
      block.call
      divisions.each do |division|
        division.motion_events.propose_from divide_event
      end
    end
    around_transition :proposed => :amended do |motion, transition, block|
      amend_event = motion.motion_events.populate_for transition.event.to_s
      amendment = motion.referred_motions.populate_amendment
      block.call
      amendment.motion_events.propose_from amend_event
    end
    before_transition all => [ :started, :proposed, :withdrawn, :adopted,
      :implemented, :rejected, :merged ] do |motion, transition|
      motion.motion_events.populate_for transition.event.to_s
    end
    after_transition all => [ :merged ] do |motion|
      motion.terminal_merged_motion.watchers << motion.watchers
    end

    state :amended, :proposed, :referred, :merged, :divided, :withdrawn, :adopted,
      :implemented, :rejected

    state :started do
      validate do |motion|
#        unless motion.referring_motion_id? || motion.sponsorships.reject(&:marked_for_destruction?).length > 0
#          errors.add :sponsorships, "cannot be empty for new motion"
#        end
      end
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

  def users_for( population, options = {} )
    include_referrers = options.delete :include_referrers || false
    users = case population
    when :sponsors
      self.users
    else
      committee.users_for population
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
    self.name ||= "Minutes of #{meeting.starts_at.to_s :long}"
    self.description ||= "Adopt minutes of #{meeting}"
    self.content ||= "RESOLVED the minutes of #{meeting} are adopted as provided below."
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

  def comment_until_must_be_in_period
    return unless comment_until && period
    unless period.starts_at < comment_until && period.ends_at > comment_until
      errors.add :comment_until, 'must be in period'
    end
  end

  def period_must_be_in_committee_schedule
    return unless period && committee
    unless committee.schedule.periods.include? period
      errors.add :period, 'must be in schedule of committee'
    end
  end
end

