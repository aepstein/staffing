class User < ActiveRecord::Base
  STATUSES = %w( staff faculty undergrad grad alumni temporary unknown )

  default_scope :order => 'users.last_name ASC, users.first_name ASC, users.middle_name ASC'

  attr_protected :admin, :net_id, :status

  has_and_belongs_to_many :qualifications
  has_many :memberships
  has_many :requests
  has_many :answers, :through => :requests
  has_many :periods, :through => :memberships
  has_many :positions, :through => :memberships

  named_scope :no_notice_since, lambda { |notice, time|
    { :conditions => ['users.id NOT IN ( SELECT user_id FROM sendings WHERE message_type = ? AND created_at > ? )',
      notice, time.utc ] }
  }

  has_attached_file :resume,
    :path => ':rails_root/db/uploads/:rails_env/users/:attachment/:id_partition/:style/:basename.:extension',
    :url => ':relative_url_root/users/:id/resume.pdf'

  acts_as_authentic do |c|
    c.login_field :net_id
  end

  scope_procedure :name_like, lambda { |name| first_name_or_last_name_or_middle_name_or_net_id_like( name ) }

  validates_attachment_size :resume, :less_than => 1.megabyte
  validates_attachment_content_type :resume, :content_type => [ 'application/pdf' ]
  validates_presence_of :net_id
  validates_uniqueness_of :net_id
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email
  validates_date :date_of_birth, :allow_nil => true, :allow_blank => true
  validates_inclusion_of :status, :in => STATUSES, :allow_blank => true

  before_validation_on_create :import_ldap_attributes, :initialize_password

  def authority_ids
    connection.select_values(
      "SELECT DISTINCT authorities.id FROM " +
      "authorities INNER JOIN committees ON authorities.committee_id = committees.id " +
      "INNER JOIN enrollments ON committees.id = enrollments.committee_id " +
      "INNER JOIN memberships ON enrollments.position_id = memberships.position_id " +
      "WHERE memberships.user_id = #{id} AND " +
      "memberships.starts_at <= #{connection.quote Date.today} AND " +
      "memberships.ends_at >= #{connection.quote Date.today}"
    ).map { |v| v.to_i }
  end

  def authorized_position_ids
    return [] if authority_ids.empty?
    Position.authority_id_equals_any( authority_ids ).all( :select => 'positions.id' ).map { |p| p.id }
  end

  def authorized_committee_ids
    return [] if authority_ids.empty?
    Committee.positions_authority_id_equals_any( authority_ids ).all( :select => 'committees.id' ).map { |c| c.id }
  end

  def requestable_committees
    Committee.requestable.positions_with_status( status ).group_by_id
  end

  def requestable_positions
    Position.requestable.with_status( status )
  end

  def requestables(reload=false)
    @requestables = nil if reload
    return @requestables if @requestables
    @requestables = requests.map { |request| request.requestable }
  end

  def role_symbols
    return [:admin,:user] if admin?
    [:user]
  end

  def name_with_net_id
    "#{name} (#{net_id})"
  end

  def name(style = nil)
    name = case style
    when :last_first
      "#{last_name}, #{first_name}"
    when :file
      self.name.strip.downcase.gsub(/[^a-z]/,'-').squeeze('-')
    when :email
      "#{email} #{self.name}"
    else
      "#{first_name} #{last_name}"
    end
    name.squeeze(' ').strip
  end

  def enrollments
    Enrollment.memberships_user_id_equals( id )
  end

  def current_enrollments
    enrollments.memberships_current
  end

  def past_enrollments
    enrollments.memberships_past
  end

  def future_enrollments
    enrollments.memberships_future
  end

  def to_s; name; end

  protected

  def initialize_password
    reset_password unless crypted_password?
  end

  def ldap_entry=(ldap_entry)
    @ldap_entry = ldap_entry
  end

  def ldap_entry
    return nil if @ldap_entry == false
    begin
      @ldap_entry ||= CornellLdap::Record.find net_id
    rescue Exception
      @ldap_entry = false
    end
  end

  def import_ldap_attributes
    if ldap_entry
      self.first_name = ldap_entry.first_name.titleize if first_name.blank? && ldap_entry.first_name
      self.middle_name = ldap_entry.middle_name.titleize if middle_name.blank? && ldap_entry.middle_name
      self.last_name = ldap_entry.last_name.titleize if last_name.blank? && ldap_entry.last_name
      self.email = "#{net_id}@cornell.edu" if email.blank? && net_id
      self.status = ldap_entry.status if ldap_entry.status
      # TODO addresses and phone numbers
    else
      self.first_name ||= 'UNKNOWN'
      self.last_name ||= 'UNKNOWN'
    end
  end
end

