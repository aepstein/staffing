class QuizQuestion < ActiveRecord::Base
  belongs_to :quiz, inverse_of: :quiz_questions
  belongs_to :question, inverse_of: :quiz_questions
  attr_accessible :position, :question_id
  attr_readonly :quiz_id, :question_id

  validates :quiz, presence: true
  validates :question, presence: true
  validates :question_id, uniqueness: { scope: :quiz_id }
  validates :position, presence: true, numericality: { greater_than: 0 }

  default_scope order { position }
end
