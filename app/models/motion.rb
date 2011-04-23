class Motion < ActiveRecord::Base
  attr_accessible :period_id, :name, :description, :complete,
    :referring_motion_id, :sponsorships_attributes
  attr_readonly :period_id

  acts_as_list :scope => [:period_id, :committee_id]

  belongs_to :period, :inverse_of => :motions
  belongs_to :committee, :inverse_of => :motions
  belongs_to :referring_motion, :inverse_of => :referred_motions, :class_name => 'Motion'

  has_many :sponsorships, :inverse_of => :motion do
    # Build and return a sponsorship if provided user is allowed
    # Otherwise, return nil
    def populate_for( user )
      build( :user => user ) if proxy_owner.users.allowed.include? user
    end
  end
  has_many :users, :through => :sponsorships do
    # Only voting members may be sponsors
    def allowed
      return [] unless proxy_owner.committee && proxy_owner.period_id?
      User.joins(:memberships) & proxy_owner.committee.memberships.where(
        'enrollments.votes > 0' ).overlap( proxy_owner.period.starts_at, proxy_owner.period.ends_at )
    end
  end
  has_many :meeting_motions, :dependent => :destroy
  has_many :meetings, :through => :meeting_motions
  has_many :motion_mergers, :inverse_of => :motion, :dependent => :destroy
  has_many :merged_motions, :through => :motion_mergers, :source => :merged_motion
  has_many :referred_motions, :inverse_of => :referring_motion, :class_name => 'Motion', :foreign_key => :referring_motion_id, :dependent => :destroy do
    def build_referee( new_committee )
      new_motion = build( proxy_owner.attributes )
      new_motion.committee = new_committee
      new_motion
    end

    def build_divided( instances=false )
      instances ||= (empty? ? 2 : 1 )
      new_motions = []
      new_attributes = proxy_owner.attributes
      %w( committee_id id position created_at updated_at ).each { |attribute| new_attributes.delete attribute }
      instances.times do |i|
        new_attributes[:name] = "#{proxy_owner.name} (#{proxy_owner.id}-#{i})"
        new_motion = build new_attributes
        new_motion.committee = proxy_owner.committee
        new_motions << new_motion
      end
      new_motions
    end

    def create_divided!( instances=false )
      with_exclusive_scope do
        build_divided( instances ).map { |motion| motion.save!; motion }
      end
    end
  end

  default_scope order( 'motions.position ASC' )
  scope :past, lambda { joins(:period) & Period.unscoped.past }
  scope :current, lambda { joins(:period) & Period.unscoped.current }

  accepts_nested_attributes_for :sponsorships, :allow_destroy => true,
    :reject_if => proc { |a| a['user_name'].blank? }

  delegate :periods, :period_ids, :to => :committee

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [ :period_id, :committee_id ]
#  validates_uniqueness_of :position, :scope => [ :period_id, :committee_id ]
  validates_presence_of :period
  validates_presence_of :committee
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

    state :started, :proposed, :referred, :merged, :divided, :closed, :adopted,
      :implemented

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
      transition :closed => :started
    end

    event :reject do
      transition [ :proposed, :adopted, :implemented ] => :rejected
    end

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

  def to_s; name; end

  protected

  def do_divide; referred_motions.create_divided!; end

  def period_must_be_in_committee_schedule
    return unless period && committee
    unless committee.schedule.periods.include? period
      errors.add :period, 'must be in schedule of committee'
    end
  end

end

