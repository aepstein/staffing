class Question < ActiveRecord::Base
  DISPOSITIONS = {
    'String' => 'string',
    'Text Box' => 'text',
    'Yes/No' => 'boolean'
  }

  scope :ordered, order { name }

  has_many :quiz_questions, inverse_of: :question, dependent: :destroy
  has_many :quizzes, through: :quiz_questions
  has_many :answers, inverse_of: :question
  has_many :membership_requests, through: :answers
  has_many :users, through: :answers

  validates :name, presence: true, uniqueness: true
  validates :content, presence: true
  validates :disposition, inclusion: { in: DISPOSITIONS.values }

  def to_s; name; end
end

