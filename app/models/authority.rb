class Authority < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :positions
  has_many :enrollments, :through => :positions
  has_many :quizzes, :through => :positions
  has_many :schedules, :through => :positions

  validates_presence_of :name
end

