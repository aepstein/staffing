class User < ActiveRecord::Base
  STATUSES = %w( staff faculty undergrad grad alumni temporary )

  default_scope order( 'users.last_name ASC, users.first_name ASC, users.middle_name ASC' )

  attr_protected :admin, :net_id, :status, :statuses, :statuses_mask

  has_and_belongs_to_many :qualifications
  has_many :memberships
  has_many :requests
  has_many :answers, :through => :requests
  has_many :periods, :through => :memberships
  has_many :positions, :through => :memberships do
    def current
      scoped.where( [
        'memberships.starts_at =< :d AND memberships.ends_at >= :d',
        { :d => Date.today }
      ] )
    end
  end

  scope :no_notice_since, lambda { |notice, time|
    where( ['users.id NOT IN ( SELECT user_id FROM sendings WHERE message_type = ? AND created_at > ? )',
      notice, time.utc ] )
  }
  scope :name_like, lambda { |name|
    where(
      %w( first_name last_name middle_name net_id ).map { |c|
        "users.#{c} LIKE " + connection.quote( "%#{text}%" )
      }.join( ' OR ' )
    )
  }

  has_attached_file :resume,
    :path => ':rails_root/db/uploads/:rails_env/users/:attachment/:id_partition/:style/:basename.:extension',
    :url => ':relative_url_root/users/:id/resume.pdf'

  acts_as_authentic do |c|
    c.login_field :net_id
  end

  validates_attachment_size :resume, :less_than => 1.megabyte, :if => lambda { |u| u.resume.file? }
  validates_attachment_content_type :resume, :content_type => [ 'application/pdf' ], :if => lambda { |u| u.resume.file? }
  validates_presence_of :net_id
  validates_uniqueness_of :net_id
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email
  validates_date :date_of_birth, :allow_nil => true, :allow_blank => true

  before_validation :import_ldap_attributes, :initialize_password, :on => :create

  def authority_ids
    authorities.map(&:id)
  end

  def authorities
    Authority.joins( "INNER JOIN committees ON authorities.committee_id = committees.id " +
      "INNER JOIN enrollments ON committees.id = enrollments.committee_id " +
      "INNER JOIN memberships ON enrollments.position_id = memberships.position_id" ).
      where( [ "memberships.user_id = :id AND memberships.starts_at <= :today AND " +
      "memberships.ends_at >= :today", { :id => id, :today => Time.zone.today } ] )
  end

  # Where necessary, provide for admin to get listing of all authorities
  def allowed_authorities
    return Authority.all if role_symbols.include? :admin
    authorities
  end

  def authorized_position_ids
    return [] if authority_ids.empty?
    Position.where( :authority_id.in => authority_ids ).select('positions.id').map(&:id)
  end

  def authorized_committee_ids
    return [] if authority_ids.empty?
    ( Committee.joins(:positions) & Position.where( :authority_id.in => authority_ids ).
      select( 'committees.id' ) ).map(&:id)
  end

  def requestable_committees
    Committee.requestable.joins(:positions) & Position.requestable_by_committee.with_status( status )
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

  def status=(status)
    self.statuses=([status])
  end

  def status
    statuses.first
  end

  def statuses=(statuses)
    self.statuses_mask = (statuses & User::STATUSES).map { |status| 2**User::STATUSES.index(status) }.sum
  end

  def statuses
    User::STATUSES.reject { |status| ((statuses_mask || 0) & 2**User::STATUSES.index(status)).zero? }
  end

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
      self.status = ldap_entry.status if statuses.empty? && ldap_entry.status
      # TODO addresses and phone numbers
    else
      self.first_name ||= 'UNKNOWN'
      self.last_name ||= 'UNKNOWN'
    end
  end
end

