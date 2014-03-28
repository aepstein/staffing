class Period < ActiveRecord::Base
  attr_readonly :schedule_id

  default_scope { order { periods.starts_at.desc } }

  scope :past, lambda { where { ends_at < Time.zone.today } }
  scope :current, lambda { overlaps( Time.zone.today, Time.zone.today ) }
  scope :recent, lambda {
    joins( "LEFT JOIN `periods` AS `next_periods` ON " +
      "#{date_add( 'periods.ends_at', 1.day )} = `next_periods`.`starts_at`" ).
    where { (starts_at.lte( Time.zone.today ) & ends_at.gte( Time.zone.today )
      ) | (next_periods.starts_at.lte( Time.zone.today ) &
      next_periods.ends_at.gte( Time.zone.today )) }
  }
  scope :overlaps, lambda { |starts, ends|
    where { |t| ( t.ends_at >= starts ) & ( t.starts_at <=  ends ) }
  }
  scope :conflict_with, lambda { |period|
    overlaps( period.starts_at, period.ends_at ).
    where( schedule_id: period.schedule_id ) }

  belongs_to :schedule, inverse_of: :periods
  has_many :motions, inverse_of: :period, dependent: :restrict_with_exception
  has_many :meetings, inverse_of: :period, dependent: :restrict_with_exception
  has_many :memberships, inverse_of: :period, dependent: :destroy do
    def populate_unassigned!
      proxy_association.owner.schedule.positions.active.each do |position|
        position.memberships.populate_unassigned_for_period! proxy_association.owner
      end
      # Reset so changes are loaded in this collection
      proxy_association.reset
    end
    def repopulate_unassigned!
      where { |t| t.starts_at < proxy_association.owner.starts_at }.update_all(
        "starts_at = #{connection.quote proxy_association.owner.starts_at}"
      )
      where { |t| t.ends_at > proxy_association.owner.ends_at }.update_all(
        "ends_at = #{connection.quote proxy_association.owner.ends_at}"
      )
      Membership.unassigned.where(period_id: proxy_association.owner.id).delete_all
      populate_unassigned!
    end
  end

  validates :schedule, presence: true
  validates :starts_at, timeliness: { type: :date }
  validates :ends_at, timeliness: { type: :date, after: :starts_at }
  validate :must_not_conflict_with_other_period

  after_create do |period|
    period.memberships.populate_unassigned!
  end
  after_update do |period|
    if period.starts_at_changed? || period.ends_at_changed?
      period.memberships.repopulate_unassigned!
    end
  end
  before_destroy do |period|
    if period.memberships.assigned.any?
      raise ::ActiveRecord::DeleteRestrictionError,
        'cannot delete period if assigned memberships are associated'
    end
  end
  
  def subsequent
    schedule.periods.where { |p| p.starts_at.eq( ends_at + 1.day ) }.first
  end

  def tense
    return nil unless starts_at && ends_at
    return :past if ends_at < Time.zone.today
    return :future if starts_at > Time.zone.today
    :current
  end

  def current?
    return false unless Time.zone.now >= starts_at.to_time && Time.zone.now <= ends_at.to_time
    true
  end

  def must_not_conflict_with_other_period
    conflicts = Period.conflict_with(self) if new_record?
    conflicts ||= Period.conflict_with(self).where { |t| t.id != id }
    errors.add :base, "Conflicts with #{conflicts.join(', ')}" unless conflicts.empty?
  end

  def to_range; starts_at..ends_at; end

  def to_s(style=nil)
    return super unless starts_at && ends_at
    case style
    when :year
      "#{starts_at.year} - #{ends_at.year}"
    else
      "#{starts_at.to_s :rfc822} - #{ends_at.to_s :rfc822}"
    end
  end

end

