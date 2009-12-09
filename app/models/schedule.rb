class Schedule < ActiveRecord::Base
  has_many :positions
  has_many :terms
  has_many :authorities, :through => :positions
  has_many :committees, :through => :positions
  has_many :quizzes, :through => :positions

  validates_presence_of :name
  validates_uniqueness_of :name
end

