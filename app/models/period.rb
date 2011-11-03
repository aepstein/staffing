class Period < ActiveRecord::Base
  attr_accessible :schedule_id, :starts_at, :ends_at
  attr_readonly :schedule_id

  default_scope order( 'periods.starts_at DESC' )

  scope :past, lambda { where { ends_at < Time.zone.today } }
  scope :current, lambda { overlaps( Time.zone.today, Time.zone.today ) }
  scope :overlaps, lambda { |starts, ends|
    where { |t| ( t.ends_at >= starts ) & ( t.starts_at <=  ends ) }
  }
  scope :conflict_with, lambda { |period|
    overlaps( period.starts_at, period.ends_at ).
    where( :schedule_id => period.schedule_id ) }

  belongs_to :schedule, inverse_of: :periods
  has_many :motions, inverse_of: :period
  has_many :meetings, inverse_of: :period
  has_many :memberships, inverse_of: :period, dependent: :destroy do
    def populate_unassigned!
      @association.owner.schedule.positions.active.each do |position|
        position.memberships.populate_unassigned_for_period! @association.owner
      end
      # Reset so changes are loaded in this collection
      reset
    end
    def repopulate_unassigned!
      where { |t| t.starts_at < @association.owner.starts_at }.update_all(
        "starts_at = #{connection.quote @association.owner.starts_at}"
      )
      where { |t| t.ends_at > @association.owner.ends_at }.update_all(
        "ends_at = #{connection.quote @association.owner.ends_at}"
      )
      Membership.unassigned.where(:period_id => @association.owner.id).delete_all
      # Reset so changes are loaded in this collection
      reset
      populate_unassigned!
    end
  end

  validates :schedule, presence: true
  validates :starts_at, timeliness: { type: :date }
  validates :ends_at, timeliness: { type: :date, after: :starts_at }
  validate :must_not_conflict_with_other_period

  after_create do |period|
    period.reload
    period.memberships.populate_unassigned!
  end
  after_update do |period|
    if period.starts_at_changed? || period.ends_at_changed?
      period.reload
      period.memberships.repopulate_unassigned!
    end
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

