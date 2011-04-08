class Question < ActiveRecord::Base
  DISPOSITIONS = {
    'String' => 'string',
    'Text Box' => 'text',
    'Yes/No' => 'boolean'
  }

  attr_accessible :name, :content, :global

  default_scope order( 'questions.name ASC' )

  has_and_belongs_to_many :quizzes
  has_many :answers, :inverse_of => :question
  has_many :requests, :through => :answers
  has_many :users, :through => :answers

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :content
  validates_inclusion_of :disposition, :in => DISPOSITIONS.values

  def to_s; name; end
end

