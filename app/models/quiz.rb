class Quiz < ActiveRecord::Base
  attr_accessible :name

  default_scope order('quizzes.name ASC')

  has_many :positions, :inverse_of => :quiz
  has_and_belongs_to_many :questions
  has_many :enrollments, :through => :positions
  has_many :authorities, :through => :positions
  has_many :schedules, :through => :positions

  validates_presence_of :name
  validates_uniqueness_of :name

  def to_s; name; end
end

