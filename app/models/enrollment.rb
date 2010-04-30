class Enrollment < ActiveRecord::Base
  default_scope :include => [ :committee, :position ], :order => 'committees.name ASC, enrollments.title ASC, positions.name ASC'

  named_scope :memberships_user_id_equals, lambda { |user_id|
    { :joins => 'INNER JOIN memberships',
      :conditions => ['memberships.position_id = enrollments.position_id AND memberships.user_id = ?', user_id] }
  }

  named_scope :memberships_current, lambda {
    { :joins => 'INNER JOIN memberships',
      :conditions => [
      'memberships.position_id = enrollments.position_id AND ' +
      'memberships.starts_at <= ? AND memberships.ends_at >= ?', Date.today, Date.today ] }
  }

  named_scope :memberships_future, lambda {
    { :joins => 'INNER JOIN memberships',
      :conditions => [
      'memberships.position_id = enrollments.position_id AND ' +
      'memberships.starts_at > ?', Date.today ] }
  }

  named_scope :memberships_past, lambda {
    { :joins => 'INNER JOIN memberships',
      :conditions => [
      'memberships.position_id = enrollments.position_id AND ' +
      'memberships.ends_at < ?', Date.today ] }
  }

  belongs_to :position
  belongs_to :committee

  has_many :memberships, :through => :position, :primary_key => 'id', :foreign_key => 'id'

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

