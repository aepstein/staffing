class Period < ActiveRecord::Base
  default_scope :order => 'periods.starts_at DESC'

  scope :current, lambda { overlaps(Date.today,Date.today) }
  scope :overlaps, lambda { |starts, ends| ends_at_gte(starts).starts_at_lte(ends) }
  scope :conflict_with, lambda { |period| overlaps(period.starts_at,period.ends_at).schedule_id_eq(period.schedule_id) }

  attr_accessor :starts_at_previously_changed, :ends_at_previously_changed
  alias :starts_at_previously_changed? :starts_at_previously_changed
  alias :ends_at_previously_changed? :ends_at_previously_changed

  belongs_to :schedule

  has_many :memberships

  validates_presence_of :schedule
  validates_date :starts_at
  validates_date :ends_at, :after => :starts_at
  validate :must_not_conflict_with_other_period

  before_update { |r|
    r.starts_at_previously_changed = r.starts_at_changed?
    r.ends_at_previously_changed = r.ends_at_changed?
  }
  after_create { |r| r.schedule.positions.each { |p| p.memberships.populate_unassigned_for_period r } }
  after_update { |r|
    return unless r.starts_at_previously_changed? || r.ends_at_previously_changed?
    r.memberships.starts_at_lt(r.starts_at).update_all( "starts_at = #{r.connection.quote r.starts_at}" )
    r.memberships.ends_at_gt(r.ends_at).update_all( "ends_at = #{r.connection.quote r.ends_at}" )
    Membership.unassigned.period_id_eq(r.id).delete_all
    r.schedule.positions(true).each { |position| position.memberships.populate_unassigned_for_period r }
  }

  def must_not_conflict_with_other_period
    conflicts = Period.conflict_with(self) if new_record?
    conflicts ||= Period.conflict_with(self).id_ne(id)
    errors.add_to_base "Conflicts with #{conflicts.join(', ')}" unless conflicts.empty?
  end

  def to_range; starts_at..ends_at; end

  def to_s; "#{starts_at.to_s :rfc822} - #{ends_at.to_s :rfc822}"; end
end

