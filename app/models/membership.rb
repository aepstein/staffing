class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :term
  belongs_to :position
  belongs_to :request

  validates_presence_of :user
  validates_presence_of :term
  validates_presence_of :position
  validates_date :starts_at
  validates_date :ends_at, :after => :starts_at
end

