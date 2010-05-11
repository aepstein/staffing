class Authority < ActiveRecord::Base
  default_scope :order => 'authorities.name ASC'

  belongs_to :committee
  has_many :positions
  has_many :enrollments, :through => :positions
  has_many :memberships, :through => :positions
  has_many :quizzes, :through => :positions
  has_many :schedules, :through => :positions

  validates_presence_of :name
  validates_uniqueness_of :name

  def effective_contact_name
    contact_name? ? contact_name : APP_CONFIG['defaults']['authority']['contact_name']
  end

  def effective_contact_email
    contact_email? ? contact_email : APP_CONFIG['defaults']['authority']['contact_email']
  end

  def committee_name; committee.name if committee; end

  def committee_name=(name)
    self.committee = Committee.find_by_name name unless name.blank?
    self.committee = nil if name.blank?
  end

  def to_s; name; end
end

