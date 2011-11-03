class Qualification < ActiveRecord::Base
  attr_accessible :name, :description

  default_scope lambda { ordered }
  scope :ordered, order { name }

  has_and_belongs_to_many :positions
  has_and_belongs_to_many :users

  validates :name, presence: true, uniqueness: true

  def to_s; name; end
end

