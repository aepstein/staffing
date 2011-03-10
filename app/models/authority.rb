class Authority < ActiveRecord::Base
  default_scope order( 'authorities.name ASC' )

  scope :user_id_equals, lambda { |user_id|
    select("DISTINCT #{arel_table.name}.*").joins(:authorized_enrollments).
    merge( Enrollment.unscoped.joins( :memberships ).
    merge( Membership.unscoped.current_or_future.where( :user_id => user_id ) ) )
  }

  belongs_to :committee, :inverse_of => :authorities
  has_many :positions, :inverse_of => :authority
  has_many :enrollments, :through => :positions
  has_many :authorized_enrollments, :primary_key => :committee_id,
    :foreign_key => :committee_id, :class_name => 'Enrollment'
  has_many :memberships, :through => :positions
  has_many :quizzes, :through => :positions
  has_many :schedules, :through => :positions
  has_many :user_renewal_notices, :inverse_of => :authority

  validates_presence_of :name
  validates_uniqueness_of :name

  def requests
    return Request.where( :id => nil ) if new_record?
    Request.authority_id_equals( id )
  end

  def effective_contact_name
    contact_name? ? contact_name : Staffing::Application.app_config['defaults']['authority']['contact_name']
  end

  def effective_contact_email
    contact_email? ? contact_email : Staffing::Application.app_config['defaults']['authority']['contact_email']
  end

  def committee_name; committee.name if committee; end

  def committee_name=(name)
    self.committee = Committee.find_by_name name unless name.blank?
    self.committee = nil if name.blank?
  end

  def to_s; name; end
end

