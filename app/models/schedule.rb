class Schedule < ActiveRecord::Base
  attr_accessible :name

  default_scope lambda { ordered }
  scope :ordered, order { name }

  has_many :positions, inverse_of: :schedule
  has_many :periods, inverse_of: :schedule do
    def active; current.first; end
  end
  has_many :authorities, through: :positions
  has_many :committees, through: :positions
  has_many :quizzes, through: :positions

  validates :name, presence: true, uniqueness: true

  def to_s; name; end
end

