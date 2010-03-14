class Authority < ActiveRecord::Base
  default_scope :order => 'authorities.name ASC'

  belongs_to :committee
  has_and_belongs_to_many :users
  has_many :positions
  has_many :enrollments, :through => :positions
  has_many :quizzes, :through => :positions
  has_many :schedules, :through => :positions

  validates_presence_of :name
  validates_uniqueness_of :name

  def committee_name; committee.name if committee; end

  def committee_name=(name)
    self.committee = Committee.find_by_name name unless name.blank?
    self.committee = nil if name.blank?
  end

  def to_s; name; end
end

