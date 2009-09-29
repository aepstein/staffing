class Term < ActiveRecord::Base
  belongs_to :schedule

  has_many :memberships
  has_many :requests

  validates_presence_of :schedule
  validates_date :starts_at
  validates_date :ends_at, :after => :starts_at
end

