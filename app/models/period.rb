class Period < ActiveRecord::Base
  default_scope :order => 'periods.starts_at DESC'

  scope_procedure :overlaps, lambda { |starts, ends| ends_at_gte(starts).starts_at_lte(ends) }
  scope_procedure :conflict_with, lambda { |period| overlaps(period.starts_at,period.ends_at).schedule_id_eq(period.schedule_id) }

  belongs_to :schedule

  has_many :memberships
  has_and_belongs_to_many :requests

  validates_presence_of :schedule
  validates_date :starts_at
  validates_date :ends_at, :after => :starts_at
  validate :must_not_conflict_with_other_period

  def must_not_conflict_with_other_period
    conflicts = Period.conflict_with(self) if new_record?
    conflicts ||= Period.conflict_with(self).id_ne(id)
    errors.add_to_base "Conflicts with #{conflicts.join(', ')}" unless conflicts.empty?
  end

  def to_s; "#{starts_at.to_s :rfc822} - #{ends_at.to_s :rfc822} period"; end
end

