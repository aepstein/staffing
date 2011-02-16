class Period < ActiveRecord::Base
  default_scope order( 'periods.starts_at DESC' )

  scope :current, lambda { overlaps(Time.zone.today,Time.zone.today) }
  scope :overlaps, lambda { |starts, ends|  where(:ends_at.gte => starts, :starts_at.lte => ends) }
  scope :conflict_with, lambda { |period| overlaps( period.starts_at, period.ends_at ).
    where( :schedule_id => period.schedule_id ) }

  belongs_to :schedule
  has_many :memberships, :dependent => :destroy do
    def populate_unassigned!
      proxy_owner.schedule.positions.each do |position|
        position.memberships.populate_unassigned_for_period! proxy_owner
      end
    end
    def repopulate_unassigned!
      where(:starts_at.lt => proxy_owner.starts_at).update_all(
        "starts_at = #{connection.quote proxy_owner.starts_at}"
      )
      where(:ends_at.gt => proxy_owner.ends_at).update_all(
        "ends_at = #{connection.quote proxy_owner.ends_at}"
      )
      Membership.unassigned.where(:period_id => proxy_owner.id).delete_all
      proxy_owner.reload
      populate_unassigned!
    end
  end

  validates_presence_of :schedule
  validates_date :starts_at
  validates_date :ends_at, :after => :starts_at
  validate :must_not_conflict_with_other_period

  after_create { |r| r.memberships.populate_unassigned! }
  after_update { |r|
    r.memberships.repopulate_unassigned! if r.starts_at_changed? || r.ends_at_changed?
  }

  def current?
    return false unless Time.zone.now >= starts_at.to_time && Time.zone.now <= ends_at.to_time
    true
  end

  def must_not_conflict_with_other_period
    conflicts = Period.conflict_with(self) if new_record?
    conflicts ||= Period.conflict_with(self).where(:id.ne => id)
    errors.add :base, "Conflicts with #{conflicts.join(', ')}" unless conflicts.empty?
  end

  def to_range; starts_at..ends_at; end

  def to_s; "#{starts_at.to_s :rfc822} - #{ends_at.to_s :rfc822}"; end

end

