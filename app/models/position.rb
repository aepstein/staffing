class Position < ActiveRecord::Base
  default_scope :order => 'positions.name ASC'

  named_scope :with_status, lambda { |status|
    { :conditions => "(positions.statuses_mask & #{2**User::STATUSES.index(status.to_s)}) > 0 OR positions.statuses_mask = 0" }
  }
  named_scope :requestable, { :conditions => { :requestable => true } }
  named_scope :unrequestable, { :conditions => { :requestable => false } }

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
    def titles_for_committee(committee)
      for_committee(committee).map { |e| e.title }.join(', ')
    end
    def votes_for_committee(committee)
      for_committee(committee).inject(0) { |sum, e| sum + e.votes }
    end
  end
  has_many :committees, :through => :enrollments

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :authority
  validates_presence_of :quiz
  validates_presence_of :schedule
  validates_numericality_of :slots, :only_integer => true, :greater_than => 0

  after_create { |r| r.memberships.populate_unassigned }
  after_update { |r|
    r.memberships.unassigned.delete_all if r.slots_changed? && r.slots_was > r.slots
    r.memberships.populate_unassigned
  }

  def statuses=(statuses)
    self.statuses_mask = (statuses & User::STATUSES).map { |status| 2**User::STATUSES.index(status) }.sum
  end

  def statuses
    User::STATUSES.reject { |status| ((statuses_mask || 0) & 2**User::STATUSES.index(status)).zero? }
  end

  def to_s; name; end
end

