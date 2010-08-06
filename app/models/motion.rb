class Motion < ActiveRecord::Base
  include AASM

  default_scope :order => 'motions.position ASC'

  attr_accessible :name, :description

  acts_as_list :scope => [:period_id, :committee_id]

  belongs_to :period
  belongs_to :user
  belongs_to :committee

  delegate :periods, :period_ids, :to => :committee

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [ :period_id, :committee_id ]
  validates_presence_of :period
  validates_presence_of :user
  validates_presence_of :committee
  validate :user_must_be_voting_in_committee

  aasm_column :status
  aasm_initial_state :draft
  aasm_state :draft
  aasm_state :proposed
  aasm_state :adopted
  aasm_state :implemented
  aasm_state :rejected

  aasm_event :propose do
    transitions :to => :proposed, :from => :draft
  end

  aasm_event :adopt do
    transitions :to => :adopted, :from => :proposed
  end

  aasm_event :implement do
    transitions :to => :implemented, :from => :adopted
  end

  aasm_event :reject do
    transitions :to => :rejected, :from => [ :proposed, :adopted, :implemented ]
  end

  def memberships
    return nil unless committee
    committee.memberships.period_id_equals( period_id ).user_id_equals( user_id ).scoped( :conditions => 'enrollments.votes > 0' )
  end

  def user_must_be_voting_in_committee
    return unless user && committee && period
    if memberships.scoped(:conditions => 'enrollments.votes > 0').empty?
      errors.add :user, 'must be voting member of committee in specified period'
    end
  end

end

