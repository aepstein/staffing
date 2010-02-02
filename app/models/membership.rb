class Membership < ActiveRecord::Base
  default_scope :include => [:user, :period],
    :order => "periods.starts_at DESC, memberships.starts_at DESC, " +
    "users.last_name ASC, users.first_name ASC, users.middle_name ASC"
  scope_procedure :assigned, lambda { user_id_not_nil }
  scope_procedure :unassigned, lambda { user_id_nil }
  scope_procedure :current, lambda { starts_at_lte(Date.today).ends_at_gte(Date.today) }

  attr_accessor :starts_at_previously_changed, :ends_at_previously_changed,
    :period_id_previously_changed, :period_id_previously_was
  alias :starts_at_previously_changed? :starts_at_previously_changed
  alias :ends_at_previously_changed? :ends_at_previously_changed
  alias :period_id_previously_changed? :period_id_previously_changed

  belongs_to :user
  belongs_to :period
  belongs_to :position
  belongs_to :request

  delegate :enrollments, :to => :position

  validates_presence_of :period
  validates_presence_of :position
  validates_date :starts_at
  validates_date :ends_at
  validate :concurrent_memberships_must_not_exceed_slots, :must_be_within_period, :user_must_be_qualified

  scope_procedure :overlap, lambda { |starts, ends| starts_at_lte(ends).ends_at_gte(starts) }

  before_save :record_previous_changes
  after_save :repopulate_unassigned
  after_destroy { |r| r.position.memberships.populate_unassigned_for_period r.period if r.user }

  def user_name
    "#{user.name} (#{user.net_id})" if user
  end

  def user_name=(name)
    self.user = User.find_or_create_by_net_id name.to_net_ids.first unless name.to_net_ids.empty?
    self.user = nil if user.id.nil?
  end

  def record_previous_changes
    self.starts_at_previously_changed = starts_at_changed?
    self.ends_at_previously_changed = ends_at_changed?
    self.period_id_previously_changed = period_id_changed?
    self.period_id_previously_was = period_id_was
  end

  def repopulate_unassigned
    return unless user
    if period_id_previously_changed? && period_id_previously_was
      position.memberships.unassigned.period_id_eq(period_id_previously_was).delete_all
      position.memberships(true).populate_unassigned_for_period Period.find(period_id_previously_was)
    end
    if starts_at_previously_changed? || ends_at_previously_changed?
      position.memberships.unassigned.period_id_eq(period_id).delete_all
      position.memberships(true).populate_unassigned_for_period period
    end
  end

  # Returns the context in which this membership should be framed (useful for polymorphic_path)
  def context
    request || position || raise( "No context is possible" )
  end

  def user_must_be_qualified
    return unless user && position
    if (position.qualification_ids - user.qualification_ids).size > 0
      errors.add :user, "is not qualified for position"
    end
  end

  def must_be_within_period
    period(true) if period && period_id && period.id != period_id
    if starts_at && ends_at && ends_at < starts_at
      errors.add :ends_at, "must be at or after #{starts_at.to_s :rfc822}"
    end
    if starts_at && period && period.starts_at > starts_at
      errors.add :starts_at, "must be within #{period}"
    end
    if ends_at && period && period.ends_at < ends_at
      errors.add :ends_at, "must be within #{period}"
    end
  end

  def concurrent_membership_counts
    scope = Membership.position_id_eq(position_id)
    scope = scope.id_ne(id) unless new_record? # exclude this record
    scope = scope.assigned if user # unassigned will be regenerated anyways
    position.memberships.edges_for(self).inject({}) do |memo, date|
      memo[date] = scope.overlap( date, date ).count
      memo[date] += 1 if starts_at <= date && ends_at >= date
      memo
    end
  end

  def concurrent_memberships_must_not_exceed_slots
    return unless starts_at && ends_at && position
    if position.slots < concurrent_membership_counts.values.sort.last
      errors.add_to_base "lacks free slots for the specified time period"
    end
  end

  def request_id=(new_id)
    self.request = Request.find(new_id) if new_id && ( request.nil? || request.id != new_id.to_i )
    write_attribute(:request_id, new_id)
  end

  def request_with_population=(new_request)
    self.period ||= new_request.periods.last
    self.starts_at ||= period.starts_at if period
    self.ends_at ||= period.ends_at if period
    self.user = new_request.user
    self.position = new_request.position
    self.request_without_population = new_request
  end

  alias_method_chain :request=, :population

end

