class Position < ActiveRecord::Base
  default_scope :order => 'positions.name ASC'

  scope :with_status, lambda { |status|
    { :conditions => "(positions.statuses_mask & #{status.nil? ? 0 : 2**User::STATUSES.index(status.to_s)}) > 0 OR positions.statuses_mask = 0" }
  }
  scope :requestable, { :conditions => { :requestable => true } }
  scope :unrequestable, { :conditions => { :requestable => false } }
  scope :renewable, { :conditions => { :renewable => true } }
  scope :unrenewable, { :conditions => { :renewable => false } }
  scope :requestable_by_committee_equals, lambda { |v|
    { :conditions => { :requestable_by_committee => v } }
  }

  belongs_to :authority
  belongs_to :quiz
  belongs_to :schedule

  has_and_belongs_to_many :qualifications
  has_many :memberships, :dependent => :destroy do
    # Create vacant memberships for all periods
    def populate_unassigned
      proxy_owner.periods.each { |p| populate_unassigned_for_period p }
    end
    # Create vacant memberships
    def populate_unassigned_for_period(period)
      return unless proxy_owner.schedule.periods.include? period
      previous_vacancies = nil
      memberships = vacancies_for_period(period).inject([]) do |memo, point|
        if previous_vacancies.nil?
          point.last.times { memo << start_unassigned(point.first, period) }
        elsif previous_vacancies < point.last
          (point.last - previous_vacancies).times { memo << start_unassigned(point.first, period) }
        elsif previous_vacancies > point.last
          (previous_vacancies - point.last).times { memo.pop.save }
        end
        memo.each { |membership| membership.ends_at = point.first }
        previous_vacancies = point.last
        memo
      end
      memberships.each { |membership| membership.save }
    end
    # Spaces for period
    def vacancies_for_period(period)
      r = edges_for(period).collect do |date|
        [date, proxy_owner.slots - overlap(date,date).position_id_eq(proxy_owner.id).count]
      end
      return [] unless r.select { |a| a.last < 0 }.empty?
      r
    end
    # Can take either a period or a membership
    def edges_for(p)
      overlap(p.starts_at,p.ends_at).inject([p.starts_at,p.ends_at]) do |memo, m|
        memo << m.starts_at - 1.day unless m.starts_at == p.starts_at
        memo << m.starts_at
        memo << m.ends_at
        memo << m.ends_at + 1.day unless m.ends_at == p.ends_at
        memo
      end.uniq.sort
    end
    private
    def start_unassigned(starts_at, period)
      build(:starts_at => starts_at, :period => period)
    end
  end
  has_many :requests, :as => :requestable
  has_many :users, :through => :memberships
  has_many :periods, :through => :schedule
  has_many :answers, :through => :requests
  has_many :enrollments, :dependent => :destroy do
    def for_committee(committee)
      self.select { |enrollment| enrollment.committee_id == committee.id }
    end
    def committees
      self.map { |enrollment| enrollment.committee.to_s }.join(', ')
    end
    def titles_for_committee(committee)
      for_committee(committee).map { |e| e.title }.join(', ')
    end
    def votes_for_committee(committee)
      for_committee(committee).inject(0) { |sum, e| sum + e.votes }
    end
  end
  has_many :committees, :through => :enrollments

  attr_accessor :slots_previously_was, :slots_previously_changed,
    :schedule_id_previously_changed, :schedule_id_previously_was

  alias :slots_previously_changed? :slots_previously_changed
  alias :schedule_id_previously_changed? :schedule_id_previously_changed

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :authority
  validates_presence_of :quiz
  validates_presence_of :schedule
  validates_numericality_of :slots, :only_integer => true, :greater_than => 0

  before_save do |position|
    position.slots_previously_was = position.slots_was
    position.slots_previously_changed = position.slots_changed?
    position.schedule_id_previously_was = position.schedule_id_was
    position.schedule_id_previously_changed = position.schedule_id_changed?
    true
  end
  after_create { |r| r.memberships.populate_unassigned }
  after_update :repopulate_unassigned

  def current_emails
    memberships.assigned.current.all(:include => [ :user ]).map { |membership| membership.user.email }
  end

  def requestables
    return [self] if requestable?
    enrollments.map { |enrollment| enrollment.committee }.select { |committee| committee.requestable? }
  end

  def statuses=(statuses)
    self.statuses_mask = (statuses & User::STATUSES).map { |status| 2**User::STATUSES.index(status) }.sum
  end

  def statuses
    User::STATUSES.reject { |status| ((statuses_mask || 0) & 2**User::STATUSES.index(status)).zero? }
  end

  def name(style=nil)
    case style
    when :file
      self.name.strip.downcase.gsub(/[^a-z]/,'-').squeeze('-')
    else
      read_attribute(:name)
    end
  end

  def to_s; name; end

  private

  def repopulate_unassigned
    if slots_previously_changed? && slots_previously_was > slots
      memberships.unassigned.delete_all
    end
    if schedule_id_previously_changed?
      memberships.unassigned.period_id_does_not_equal_any( schedule.period_ids ).delete_all
    end
    if schedule_id_previously_changed? || slots_previously_changed?
      schedule.periods.each do |period|
        memberships(true).populate_unassigned_for_period period
      end
    end
  end

end

