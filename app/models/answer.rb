class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :request

  validates_presence_of :request
  validates_presence_of :question
  validates_presence_of :content
  validate :question_must_be_allowed

  scope_procedure :global, lambda { question_global_equals true }
  scope_procedure :local, lambda { question_global_ne true }

  def question_must_be_allowed
    return nil unless request
    unless request.allowed_questions.include?(question)
      errors.add :question, "is not allowed for this position"
    end
  end
end

