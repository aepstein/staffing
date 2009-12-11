class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :request

  validates_presence_of :request
  validates_presence_of :question
  validates_presence_of :content
  validate :question_must_be_allowed

  def question_must_be_allowed
    return nil unless request
    unless request.position.quiz.questions.include?(question)
      errors.add :question, "is not allowed for this position"
    end
  end
end

