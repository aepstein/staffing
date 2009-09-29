class Request < ActiveRecord::Base
  belongs_to :term
  belongs_to :position
  belongs_to :user

  has_one :membership

  validates_presence_of :term
  validates_presence_of :position
  validates_presence_of :user
end

