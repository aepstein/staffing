class Position < ActiveRecord::Base
  belongs_to :authority
  belongs_to :committee
  belongs_to :quiz
  belongs_to :schedule

  has_and_belongs_to_many :qualifications
  has_many :memberships
  has_many :requests
  has_many :users, :through => :memberships
  has_many :terms, :through => :memberships
  has_many :answers, :through => :requests

  validates_presence_of :authority
  validates_presence_of :committee
  validates_presence_of :quiz
  validates_presence_of :schedule
  validates_numericality_of :slots, :only_integer => true, :greater_than => 0
  validates_presence_of :voting
end

