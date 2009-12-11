class Authority < ActiveRecord::Base
  default_scope :order => 'authorities.name ASC'

  has_and_belongs_to_many :users
  has_many :positions
  has_many :enrollments, :through => :positions
  has_many :quizzes, :through => :positions
  has_many :schedules, :through => :positions

  validates_presence_of :name
  validates_uniqueness_of :name

  def to_s; name; end
end

