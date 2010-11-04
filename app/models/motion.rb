class Motion < ActiveRecord::Base
  include AASM

  default_scope :order => 'motions.position ASC'

  attr_protected :committee_id
  attr_readonly :period_id, :user_id

  acts_as_list :scope => [:period_id, :committee_id]

  belongs_to :period
  belongs_to :user
  belongs_to :committee
  belongs_to :referring_motion, :class_name => 'Motion'

  has_many :motion_mergers, :dependent => :destroy
  has_many :merged_motions, :through => :motion_mergers, :source => :merged_motion
  has_many :referred_motions, :class_name => 'Motion', :foreign_key => :referring_motion_id, :dependent => :destroy do
    def build_referee( new_committee )
      new_motion = build( proxy_owner.attributes )
      new_motion.committee = new_committee
      new_motion
    end

    def build_divided( instances=false )
      instances ||= (empty? ? 2 : 1 )
      new_motions = []
      instances.times do |i|
        new_motion = build( proxy_owner.attributes.merge( { :name => "#{proxy_owner.name} (#{proxy_owner.id}-#{i})" } ) )
        new_motion.committee = proxy_owner.committee
        new_motions << new_motion
      end
      new_motions
    end

    def create_divided( instances=false )
      build_divided( instances ).map { |motion| motion.save!; motion }
    end
  end

  delegate :periods, :period_ids, :to => :committee

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [ :period_id, :committee_id ]
  validates_presence_of :period
  validates_presence_of :user
  validates_presence_of :committee
  validate :user_must_be_voting_in_committee

  before_create do |motion|
    if motion.referee?
      motion.referring_motion.lock!
      motion.referring_motion.refer!
    end
  end

  after_create do |motion|
    motion.referring_motion.save! if motion.referee?
  end

  aasm_column :status
  aasm_initial_state :started
  aasm_state :started
  aasm_state :proposed
  aasm_state :referred
  aasm_state :merged
  aasm_state :divided, :before_enter => :do_divide
  aasm_state :closed
  aasm_state :adopted
  aasm_state :implemented

  aasm_event :propose do
    transitions :to => :proposed, :from => :started
  end

  aasm_event :adopt do
    transitions :to => :adopted, :from => :proposed
  end

  aasm_event :merge do
    transitions :to => :merged, :from => :proposed
  end

  aasm_event :divide do
    transitions :to => :divided, :from => :proposed
  end

  aasm_event :refer do
    transitions :to => :referred, :from => [ :proposed, :adopted ]
  end

  aasm_event :implement do
    transitions :to => :implemented, :from => :adopted
  end

  aasm_event :reject do
    transitions :to => :rejected, :from => [ :proposed, :adopted, :implemented ]
  end

  aasm_event :restart do
    transitions :to => :started, :from => :closed
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

  def memberships
    return nil unless committee
    committee.memberships.where( 'enrollments.votes > 0', :period_id => period_id, :user_id => user_id )
  end

  protected

  def do_divide; referred_motions.create_divided; end

  # User must have a vote in the committee associated with this motion unless
  # it has been referred or divided
  def user_must_be_voting_in_committee
    return unless user && committee && period
    if referring_motion.blank? && memberships.empty?
      errors.add :user, 'must be voting member of committee in specified period'
    end
  end

end

