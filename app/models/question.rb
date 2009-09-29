class Question < ActiveRecord::Base
  has_and_belongs_to_many :quizzes
  has_many :answers
  has_many :requests, :through => :answers
  has_many :users, :through => :answers

  validates_presence_of :name
  validates_presence_of :content
  validates_presence_of :global
end

