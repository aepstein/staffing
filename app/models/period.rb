class Period < ActiveRecord::Base
  default_scope :order => 'periods.starts_at DESC'

  belongs_to :schedule

  has_many :memberships
  has_and_belongs_to_many :requests

  validates_presence_of :schedule
  validates_date :starts_at
  validates_date :ends_at, :after => :starts_at
end

