class Answer < ActiveRecord::Base
  attr_accessible :question_id, :content
  attr_readonly :question_id

  belongs_to :question, :inverse_of => :answers
  belongs_to :request, :inverse_of => :answers

  validates_presence_of :request
  validates_presence_of :question
  validates_presence_of :content
  validate :question_must_be_allowed

  scope :global, lambda { joins(:question).where :questions => { :global.eq => true } }
  scope :local, lambda { joins(:question).where { questions.global != true } }

  def question_must_be_allowed
    return nil unless request
    unless request.questions.include?(question)
      errors.add :question, "is not allowed for this position"
    end
  end
end

