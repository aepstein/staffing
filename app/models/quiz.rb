class Quiz < ActiveRecord::Base
  attr_accessible :name

  default_scope lambda { ordered }
  scope :ordered, order { name }

  has_many :positions, inverse_of: :quiz
  has_and_belongs_to_many :questions
  has_many :enrollments, through: :positions
  has_many :authorities, through: :positions
  has_many :schedules, through: :positions

  validates :name, presence: true, uniqueness: true

  def to_s; name; end
end

