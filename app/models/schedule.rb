class Schedule < ActiveRecord::Base
  default_scope :order => 'schedules.name ASC'

  has_many :positions
  has_many :periods
  has_many :authorities, :through => :positions
  has_many :committees, :through => :positions
  has_many :quizzes, :through => :positions

  validates_presence_of :name
  validates_uniqueness_of :name

  def to_s; name; end
end

