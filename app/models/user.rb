class User < ActiveRecord::Base
  notifiable_events :renew
  has_ldap_entry :net_id
  has_phone :mobile_phone, :work_phone, :home_phone

  STATUSES = %w( staff faculty undergrad grad alumni temporary )
  
  has_paper_trail

  has_many :motion_votes, inverse_of: :user, dependent: :delete_all  
  has_many :memberships, inverse_of: :user do
    # Return memberships a user is authorized to review
    # User must have voting membership with future end date in committee of
    # authority for the position of the membership which overlaps the membership's
    # duration
    def authorized
      Membership.authorized_user_id_equals proxy_association.owner.id
    end
    def current_position_ids
      @current_position_ids ||= current.value_of(:position_id)
    end
  end
  has_many :enrollments, through: :memberships do
    def past; where { memberships.ends_at < Time.zone.today }; end
    def current
      where { memberships.starts_at <= Time.zone.today }.
      where { memberships.ends_at >= Time.zone.today }
    end
    def current_ids_with_roles( roles )
      @current_ids_with_roles ||= Hash.new
      @current_ids_with_roles[ roles ] ||= current.with_roles(roles).
        value_of(:id)
    end
    def future; where { memberships.starts_at > Time.zone.today }; end
    def prospective
      where { memberships.ends_at >= Time.zone.today }
    end
  end
  has_many :committees, through: :enrollments do
    def past; where { enrollments.memberships.ends_at < Time.zone.today }; end
    def current
      where { enrollments.memberships.starts_at <= Time.zone.today }.
      where { enrollments.memberships.ends_at >= Time.zone.today }
    end
    def future; where { enrollments.memberships.starts_at > Time.zone.today }; end
    def prospective; where { enrollments.memberships.ends_at >= Time.zone.today }; end
    def requestable
      Committee.requestable_for_user(proxy_association.owner)
    end
    def authorized(votes = 1)
      Committee.where { |c| c.id.in( Enrollment.select { committee_id }.
        where { |e| e.position_id.in(
          Position.select { id }.where { |p| p.authority_id.in(
            proxy_association.owner.authorities.authorized( votes ).
            select { id } ) } ) } ) }
    end
  end
  # Meetings which coincide with a membership
  has_many :meetings, -> { where(
    "memberships.starts_at <= meetings.starts_at " +
    "AND #{Membership.date_add :ends_at, 1, :days} > meetings.starts_at" ).
    distinct },
    through: :committees
  has_many :authorities, through: :committees do
    def prospective
      where { committees.enrollments.memberships.ends_at > Time.zone.today }
    end
    def authorized( votes = 1 )
      return Authority.unscoped if ( proxy_association.owner.role_symbols & [ :admin, :staff ] ).any?
      prospective.where { |a| a.committees.enrollments.votes.gte( votes ) }
    end
  end
  has_many :designees, inverse_of: :user
  has_many :membership_requests, inverse_of: :user
  # User has permission to review requests that overlap with authority to staff
  has_many :reviewable_membership_requests, -> { where( [
    "membership_requests.starts_at <= memberships.ends_at AND " +
    "membership_requests.ends_at >= memberships.starts_at AND " +
    "memberships.ends_at >= ?", Time.zone.today ] ).
    includes(:user).references(:user).distinct },
    through: :authorities, source: :membership_requests
  # User has permission to review memberships that overlap with authority to staff
  has_many :reviewable_memberships, -> { where( [
    "memberships_reviewable_memberships_join.starts_at <= memberships.ends_at AND " +
    "memberships_reviewable_memberships_join.ends_at >= memberships.starts_at AND " +
    "memberships.ends_at >= ?", Time.zone.today ] ).
    distinct },
    through: :authorities, source: :memberships
  # User has permission to renew or decline renewal
  has_many :renewable_memberships, -> { where( [
    "memberships_renewable_memberships_join.starts_at <= memberships.renew_until AND " +
    "memberships_renewable_memberships_join.ends_at > memberships.ends_at AND " +
    "memberships.renew_until >= ?", Time.zone.today ] ).
    distinct },
    through: :authorities, source: :memberships
  has_many :sponsorships, inverse_of: :user
  has_many :motions, through: :sponsorships
  has_many :peer_motions, -> { where [
    "motions.period_id IN (SELECT id FROM periods WHERE periods.starts_at <= " +
    "memberships.ends_at AND periods.ends_at >= memberships.starts_at) AND " +
    "memberships.ends_at >= ?", Time.zone.today ] },
    through: :committees, source: :motions
    
  has_and_belongs_to_many :watched_motions, class_name: 'Motion',
    join_table: 'motions_watchers'
  has_many :answers, through: :membership_requests
  has_many :periods, through: :memberships
  has_many :positions, through: :memberships do
    def current
      all.where(
        'memberships.starts_at <= :d AND memberships.ends_at >= :d',
        { d: Time.zone.today }
      )
    end
    def requestable
      Position.assignable_to( proxy_association.owner ).
        where { |p| p.id.in( Enrollment.unscoped.requestable ) }
    end
    def authorized(votes = 1)
      return [] if proxy_association.owner.authorities.authorized(votes).empty?
      Position.where { |p| p.authority_id.in proxy_association.owner.authorities.
          authorized( votes ).map(&:id) }.select('DISTINCT positions.*')
    end
  end
  has_many :declined_memberships, class_name: 'Membership',
    foreign_key: :declined_by_user_id, inverse_of: :declined_by_user,
    dependent: :nullify
  has_many :motion_comments, inverse_of: :user, dependent: :destroy

  scope :ordered, lambda { order { [ last_name, first_name, middle_name ] } }
  scope :assignable_to, lambda { |position|
    if position.statuses_mask > 0
      with_statuses_mask( position.statuses_mask )
    else
      all
    end
  }
  scope :renewable_to, lambda { |membership|
    select('DISTINCT users.*').joins(:memberships).merge( Membership.unscoped.renewable_to( membership ) )
  }
  scope :renewal_unconfirmed, lambda {
    where { id.in( Membership.unscoped.joins( :period ).
      renewal_unconfirmed.select { user_id } ) }
  }
  scope :with_status, lambda { |status|
    where( "users.statuses_mask & #{status.nil? ? 0 : 2**User::STATUSES.index(status.to_s)} > 0" )
  }
  scope :with_statuses_mask, lambda { |statuses_mask|
    where( "users.statuses_mask & ? > 0", statuses_mask )
  }
  scope :name_cont, lambda { |name|
    where(
      %w( first_name last_name middle_name net_id ).map { |c|
        "users.#{c} LIKE :name"}.join( ' OR ' ), :name => "%#{name}%"
    )
  }
  scope :with_enrollments, lambda {
    joins(:memberships).
    joins("INNER JOIN enrollments " +
      "ON memberships.position_id = enrollments.position_id")
  }

  search_methods :name_cont
  ransacker :name
  ## TODO: Ideally, the following or similar could substitute for name_cont
#  ransacker :name, :type => :string do |parent|
#    Arel::Nodes::InfixOperation.new(' ',
#      Arel::Nodes::SqlLiteral.new('CONCAT'),
#      Arel::Nodes::Grouping.new( [
#        parent.table[:first_name], ' ',
#        parent.table[:last_name],
#        parent.table[:net_id]
#      ] )
#    )
#  end

  mount_uploader :resume, UserResumeUploader
  mount_uploader :portrait, PortraitUploader

  is_authenticable

  validates :net_id, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :date_of_birth, timeliness: { type: :date, allow_nil: true,
    allow_blank: true }
  validates :renewal_checkpoint, timeliness: { type: :datetime }
  validates :empl_id, uniqueness: { allow_blank: true }
  validates_integrity_of :resume
  validate do |user|
    if user.resume.present? && user.resume.size > 1.megabyte
      errors.add :resume, 'file size is large than the permitted 1 megabyte'
    end
  end

  accepts_nested_attributes_for :memberships

  before_validation :import_ldap_attributes, on: :create
  before_validation { |r| r.renewal_checkpoint ||= Time.zone.now unless r.persisted? }

  def self.permitted_attributes( role=nil )
    case role
    when :admin
      permitted_attributes(:staff) + [ :admin, :staff ]
    when :staff
      permitted_attributes + [ :net_id, :empl_id, :status ]
    else
      [ :id, :first_name, :middle_name, :last_name, :email,
        :mobile_phone, :work_phone, :home_phone, :work_address, :date_of_birth,
        :resume, :portrait, :renewal_checkpoint, :password,
        :password_confirmation ]
    end
  end

  def self.import_empl_id_from_csv_string( string )
    import_empl_id_from_csv( CSV.parse(string) )
  end

  def self.import_empl_id_from_csv_file( file )
    import_empl_id_from_csv( CSV.parse(file.read) )
  end

  def self.import_empl_id_from_csv(values)
    # TODO
    # For every 1000 entries, prepare & execute update statement
    values.select! { |row| row.length == 2 }
    return 0 if values.empty?
    count = 0
    while ( focus = values.slice!(0,1000) ).any? do
      focus.map! { |row| "WHEN #{connection.quote row.first} " +
        "THEN #{connection.quote row.last.to_i}" }
      count += User.unscoped.update_all("empl_id = (CASE net_id #{focus.join ' '} " +
        "ELSE empl_id END)")
    end
    count
  end

  def requestables(reload=false)
    @requestables = nil if reload
    return @requestables if @requestables
    @requestables = membership_requests.map { |membership_request| membership_request.requestable }
  end

  def role_symbols
    return @role_symbols if @role_symbols
    @role_symbols ||= [:user]
    @role_symbols << :admin if admin?
    @role_symbols << :authority if authorities.any?
    @role_symbols << :staff if staff?
    @role_symbols
  end

  def name(style = nil)
    name = case style
    when :last_first
      "#{last_name}, #{first_name}"
    when :file
      self.name.strip.downcase.gsub(/[^a-z]/,'-').squeeze('-')
    when :email
      "#{email} #{self.name}"
    when :net_id
      "#{self.name} (#{net_id})"
    else
      "#{first_name} #{last_name}"
    end
    name.squeeze(' ').strip
  end

  def to_s; name; end

  def to_email
    "#{name} <#{email}>"
  end

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

  def refresh
    return if updated_at < ( Time.zone.now - 1.month )
    if ldap_entry
      self.status = ldap_entry.status if ldap_entry.status
      import_ldap_attributes
      save
    end
  end

  protected

  def memberships_scope(tense = nil)
    scope = Membership.unscoped.where( :user_id => id )
    tense.blank? ? scope : scope.send( tense )
  end

  def import_ldap_attributes
    if ldap_entry
      self.first_name ||= ldap_entry.first_name.titleize if ldap_entry.first_name
      self.middle_name ||= ldap_entry.middle_name.titleize if ldap_entry.middle_name
      self.last_name ||= ldap_entry.last_name.titleize if ldap_entry.last_name
      self.email ||= "#{net_id}@cornell.edu" if net_id
      self.status ||= ldap_entry.status if ldap_entry.status
      self.home_phone ||= ldap_entry.home_phone if ldap_entry.home_phone
      self.work_phone ||= ldap_entry.campus_phone if ldap_entry.campus_phone
      self.mobile_phone ||= ldap_entry.mobile_phone if ldap_entry.mobile_phone
      # TODO addresses
    else
      self.first_name ||= 'UNKNOWN'
      self.last_name ||= 'UNKNOWN'
    end
  end
end

