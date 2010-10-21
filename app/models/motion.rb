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
    def build_referred( new_committee )
      new_motion = build( proxy_owner.attributes )
      new_motion.committee = new_committee
    end

    def build_divided( instances=false )
      instances ||= (empty? ? 2 : 1 )
      new_motions = []
      instances.times do
        new_motions << build( proxy_owner.attributes )
      end
      new_motions
    end

    def create_divided( instances=false )
      build_divided( instances ).each { |m|  }
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
    motion.referring_motion.lock! if referee?
    motion.referring_motion.refer!
  end

  after_create do |motion|
    motion.referring_motion.save! if referee?
  end

  aasm_column :status
  aasm_initial_state :started
  aasm_state :started
  aasm_state :proposed
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
    transitions :to => :closed, :from => :proposed
  end

  aasm_event :divide do
    transitions :to => :closed, :from => :proposed, :before_enter => :do_divide
  end

  aasm_event :refer do
    transitions :to => :closed, :from => [ :proposed, :adopted ]
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

  # Motion has been referred to another committee
  def referred?
    return true if ( referred_motions.length == 1 ) && ( referred_motions.first.committee != committee )
    false
  end

  # Motion has been referred from another committee
  def referee?
    return true if referring_motion && ( referring_motion.committee != committee )
    false
  end

  # Motion has been divided
  def divided?
    return true unless ( referred_motions.length == 0 ) || ( referred_motions.first.committee != committee )
    false
  end

  def memberships
    return nil unless committee
    committee.memberships.period_id_equals( period_id ).user_id_equals( user_id ).scoped( :conditions => 'enrollments.votes > 0' )
  end

  protected

  def do_divide; referred_motions.build_divided.each { |m| m.save }; end

  def user_must_be_voting_in_committee
    return unless user && committee && period
    if memberships.scoped(:conditions => 'enrollments.votes > 0').empty?
      errors.add :user, 'must be voting member of committee in specified period'
    end
  end

end

