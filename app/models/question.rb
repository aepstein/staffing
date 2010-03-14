class Question < ActiveRecord::Base
  ALLOWED_FORMATS = {
    'String' => 'string',
    'Text Box' => 'text',
    'Yes/No' => 'boolean'
  }
  default_scope :order => 'questions.name ASC'

  has_and_belongs_to_many :quizzes
  has_many :answers
  has_many :requests, :through => :answers
  has_many :users, :through => :answers

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :content
  validates_inclusion_of :format, :in => ALLOWED_FORMATS.values

  def to_s; name; end
end

