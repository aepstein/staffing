class Enrollment < ActiveRecord::Base
  default_scope :include => [ :position ], :order => 'enrollments.title ASC, positions.name ASC'

  belongs_to :position
  belongs_to :committee

  validates_presence_of :position
  validates_presence_of :committee
  validates_presence_of :title
  validates_numericality_of :votes, :greater_than_or_equal_to => 0, :only_integer => true
end

