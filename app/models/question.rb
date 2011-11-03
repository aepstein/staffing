class Question < ActiveRecord::Base
  DISPOSITIONS = {
    'String' => 'string',
    'Text Box' => 'text',
    'Yes/No' => 'boolean'
  }

  attr_accessible :name, :content, :global, :disposition, :quiz_ids

  default_scope lambda { ordered }
  scope :ordered, order { name }

  has_and_belongs_to_many :quizzes
  has_many :answers, inverse_of: :question
  has_many :requests, through: :answers
  has_many :users, through: :answers

  validates :name, presence: true, uniqueness: true
  validates :content, presence: true
  validates :disposition, inclusion: { in: DISPOSITIONS.values }

  def to_s; name; end
end

