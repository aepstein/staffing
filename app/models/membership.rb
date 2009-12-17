class Membership < ActiveRecord::Base
  default_scope :include => [:user, :period],
    :order => "periods.starts_at DESC, memberships.starts_at DESC, " +
    "users.last_name ASC, users.first_name ASC, users.middle_name ASC"

  belongs_to :user
  belongs_to :period
  belongs_to :position
  belongs_to :request

  validates_presence_of :user
  validates_presence_of :period
  validates_presence_of :position
  validates_date :starts_at
  validates_date :ends_at
  validate :concurrent_memberships_must_not_exceed_slots, :must_be_within_period

  scope_procedure :overlaps, lambda { |starts, ends| starts_at_lte(ends).ends_at_gte(starts) }

  # Returns the context in which this membership should be framed (useful for polymorphic_path)
  def context
    return request if request
    position
  end

  def must_be_within_period
    period(true) if period && period_id && period.id != period_id
    if starts_at && ends_at && ends_at < starts_at
      errors.add :ends_at, "must be before #{starts_at.to_s :rfc822}"
    end
    if starts_at && period && period.starts_at > starts_at
      errors.add :starts_at, "must be within #{period}"
    end
    if ends_at && period && period.ends_at < ends_at
      errors.add :ends_at, "must be within #{period}"
    end
  end

  def concurrent_membership_edges
    memberships = Membership.overlaps(starts_at, ends_at).position_id_eq(position_id)
    memberships = memberships.id_ne(id) unless new_record?
    memberships.inject([starts_at, ends_at]) do |memo, membership|
      memo << membership.starts_at unless membership.starts_at < starts_at
      memo << membership.ends_at unless membership.ends_at > ends_at
      memo
    end.uniq.sort
  end

  def concurrent_membership_counts
    concurrent_membership_edges.inject({}) do |memo, date|
      memo[date] = Membership.overlaps( date, date ).position_id_eq(position_id).count
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

