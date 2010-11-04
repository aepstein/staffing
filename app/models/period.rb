class Period < ActiveRecord::Base
  default_scope :order => 'periods.starts_at DESC'

  scope :current, lambda { overlaps(Time.zone.today,Time.zone.today) }
  scope :overlaps, lambda { |starts, ends|  where(:ends_at.gte => starts, :starts_at.lte => ends) }
  scope :conflict_with, lambda { |period| overlaps( period.starts_at, period.ends_at ).
    where( :schedule_id => period.schedule_id ) }

  belongs_to :schedule

  has_many :memberships

  validates_presence_of :schedule
  validates_date :starts_at
  validates_date :ends_at, :after => :starts_at
  validate :must_not_conflict_with_other_period

  after_create { |r| r.schedule.positions.each { |p| p.memberships.populate_unassigned_for_period r } }
  after_update { |r|
    return unless r.starts_at_previously_changed? || r.ends_at_previously_changed?
    r.memberships.where(:starts_at.lt => r.starts_at).update_all( "starts_at = #{r.connection.quote r.starts_at}" )
    r.memberships.where(:ends_at.gt => r.ends_at).update_all( "ends_at = #{r.connection.quote r.ends_at}" )
    Membership.unassigned.where(:period_id => r.id).delete_all
    r.schedule.positions(true).each { |position| position.memberships.populate_unassigned_for_period r }
  }

  def must_not_conflict_with_other_period
    conflicts = Period.conflict_with(self) if new_record?
    conflicts ||= Period.conflict_with(self).where(:id.ne => id)
    errors.add :base, "Conflicts with #{conflicts.join(', ')}" unless conflicts.empty?
  end

  def to_range; starts_at..ends_at; end

  def to_s; "#{starts_at.to_s :rfc822} - #{ends_at.to_s :rfc822}"; end
end

