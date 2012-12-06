class Quiz < ActiveRecord::Base
  attr_accessible :name, :quiz_questions_attributes

  default_scope lambda { ordered }
  scope :ordered, order { name }

  has_many :positions, inverse_of: :quiz, dependent: :restrict
  has_many :quiz_questions, inverse_of: :quiz, dependent: :destroy
  has_many :questions, through: :quiz_questions
  has_many :enrollments, through: :positions
  has_many :authorities, through: :positions
  has_many :schedules, through: :positions

  accepts_nested_attributes_for :quiz_questions, allow_destroy: true

  validates :name, presence: true, uniqueness: true

  def to_s; name? ? name : super; end
end

