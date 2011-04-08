class Enrollment < ActiveRecord::Base
  attr_accessible :committee_id, :position_name, :position_id, :title, :votes
  attr_readonly :committee_id

  belongs_to :position, :inverse_of => :enrollments
  belongs_to :committee, :inverse_of => :enrollments
  has_many :memberships, :primary_key => :position_id, :foreign_key => :position_id

  default_scope includes(:committee, :position).
    order( 'committees.name ASC, enrollments.title ASC, positions.name ASC' )

  scope :memberships_user_id_equals, lambda { |user_id|
     joins(:memberships).merge( Membership.where( :user_id => user_id ) )
  }
  scope :memberships_current, lambda { joins(:memberships) & Membership.current }
  scope :memberships_future, lambda { joins(:memberships) & Membership.future }
  scope :memberships_past, lambda { joins(:memberships) & Membership.past }

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

