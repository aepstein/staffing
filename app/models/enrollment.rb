class Enrollment < ActiveRecord::Base
  default_scope :include => [ :position ], :order => 'enrollments.title ASC, positions.name ASC'

  belongs_to :position
  belongs_to :committee

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

