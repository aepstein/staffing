class Enrollment < ActiveRecord::Base
  attr_accessible :committee_id, :position_name, :position_id, :title, :votes,
    :requestable, :membership_notices
  attr_readonly :committee_id

  belongs_to :position, inverse_of: :enrollments
  belongs_to :committee, inverse_of: :enrollments
  has_many :memberships, through: :position
  has_many :users, through: :memberships

  scope :ordered, includes( :committee, :position ).
    order { [ committees.name, title, positions.name ] }
  scope :membership_notices, where( membership_notices: true )
  scope :requestable, where { requestable.eq(true) }
  scope :unrequestable, where { requestable.not_eq(true) }

  validates :position, presence: true
  validates :committee, presence: true
  validates :title, presence: true
  validates :votes,
    numericality: { greater_than_or_equal_to: 0, only_integer: true }

  def position_name; position.name if position; end

  def position_name=(name)
    self.position = Position.find_by_name name unless name.blank?
    self.position = nil if name.blank?
  end

end

