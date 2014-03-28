class Schedule < ActiveRecord::Base
  default_scope { ordered }
  scope :ordered, -> { order { schedules.name } }

  has_many :positions, inverse_of: :schedule, dependent: :destroy
  has_many :periods, inverse_of: :schedule, dependent: :destroy do
    def active; current.first; end
  end
  has_many :authorities, through: :positions
  has_many :committees, through: :positions
  has_many :quizzes, through: :positions

  accepts_nested_attributes_for :periods, allow_destroy: true

  validates :name, presence: true, uniqueness: true

  def to_s; name; end
end

