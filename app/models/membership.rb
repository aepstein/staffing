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

  def period_starts_at
    return nil unless period
    period.starts_at
  end

  def period_ends_at
    return nil unless period
    period.ends_at
  end

end

