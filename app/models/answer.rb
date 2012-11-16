class Answer < ActiveRecord::Base
  attr_accessible :question_id, :content
  attr_readonly :question_id

  belongs_to :question, inverse_of: :answers
  belongs_to :membership_request, inverse_of: :answers

  validates :membership_request, presence: true
  validates :question, presence: true
  validates :content, presence: true
  validate :question_must_be_allowed, on: :create

  scope :global, lambda { joins(:question).where { questions.global == true } }
  scope :local, lambda { joins(:question).where { questions.global != true } }

  def question_must_be_allowed
    return nil unless membership_request
    unless membership_request.questions.include?(question)
      errors.add :question, "is not allowed for this position"
    end
  end
end

