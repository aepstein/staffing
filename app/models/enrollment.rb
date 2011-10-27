class Enrollment < ActiveRecord::Base
  attr_accessible :committee_id, :position_name, :position_id, :title, :votes,
    :membership_notices
  attr_readonly :committee_id

  belongs_to :position, :inverse_of => :enrollments
  belongs_to :committee, :inverse_of => :enrollments
  has_many :memberships, :through => :position

  default_scope includes(:committee, :position).
    order( 'committees.name ASC, enrollments.title ASC, positions.name ASC' )

  scope :membership_notices, where( :membership_notices => true )

  validates_presence_of :position
  validates_presence_of :committee
  validates_presence_of :title
  validates_numericality_of :votes, :greater_than_or_equal_to => 0, :only_integer => true

  def position_name; position.name if position; end

  def position_name=(name)
    self.position = Position.find_by_name name unless name.blank?
    self.position = nil if name.blank?
  end

end

