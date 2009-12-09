class Request < ActiveRecord::Base
  has_and_belongs_to_many :periods
  belongs_to :position
  belongs_to :user

  has_one :membership

  validates_presence_of :position
  validates_presence_of :user
  validate :must_have_periods

  def must_have_periods
    errors.add :periods, "must be selected." if periods.empty?
  end
end

