class Position < ActiveRecord::Base
  default_scope :order => 'positions.name ASC'

  belongs_to :authority
  belongs_to :quiz
  belongs_to :schedule

  has_and_belongs_to_many :qualifications
  has_many :memberships do
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
          (previous_vacancies - point.last).times { end_unassigned memo.pop, point.first }
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
    def end_unassigned(membership, ends_at)
      membership.ends_at = ends_at
      membership.save
    end
  end
  has_many :requests
  has_many :users, :through => :memberships
  has_many :periods, :through => :schedule
  has_many :answers, :through => :requests

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

  def to_s; name; end
end

