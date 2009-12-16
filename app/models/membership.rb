class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :period
  belongs_to :position
  belongs_to :request

  validates_presence_of :user
  validates_presence_of :period
  validates_presence_of :position
  validates_date :starts_at, :on_or_after => :period_starts_at
  validates_date :ends_at, :after => :starts_at, :on_or_before => :period_ends_at
  validate :concurrent_memberships_must_not_exceed_slots

  scope_procedure :overlaps, lambda { |starts, ends| starts_at_lte(ends).ends_at_gte(starts) }

  def period_starts_at
    return starts_at unless period
    period.starts_at
  end

  def period_ends_at
    return ends_at unless period
    period.ends_at
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

end

