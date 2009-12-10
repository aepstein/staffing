class Question < ActiveRecord::Base
  default_scope :order => 'questions.name ASC'

  has_and_belongs_to_many :quizzes
  has_many :answers
  has_many :requests, :through => :answers
  has_many :users, :through => :answers

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :content
end

