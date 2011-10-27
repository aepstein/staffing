class User < ActiveRecord::Base
  include Notifiable
  notifiable_events :renew

  STATUSES = %w( staff faculty undergrad grad alumni temporary )
  ADMIN_UPDATABLE = [ :net_id, :admin, :status ]
  UPDATABLE = [ :first_name, :middle_name, :last_name, :email, :mobile_phone,
    :work_phone, :home_phone, :work_address, :date_of_birth, :resume,
    :renewal_checkpoint, :memberships_attributes ]

  attr_accessible UPDATABLE
  attr_accessible ADMIN_UPDATABLE, UPDATABLE, as: :admin

  default_scope order( 'users.last_name ASC, users.first_name ASC, users.middle_name ASC' )

  has_and_belongs_to_many :qualifications
  has_many :memberships, :inverse_of => :user do
    # Return memberships a user is authorized to review
    # User must have voting membership with future end date in committee of
    # authority for the position of the membership which overlaps the membership's
    # duration
    def authorized
      Membership.authorized_user_id_equals @association.owner.id
    end
  end
  has_many :enrollments, :through => :memberships do
    def past; where { memberships.ends_at < Time.zone.today }; end
    def current
      where { memberships.starts_at <= Time.zone.today &&
        memberships.ends_at >= Time.zone.today }
    end
    def future; where { memberships.starts_at > Time.zone.today }; end
  end
  has_many :committees, :through => :enrollments do
    def past; where { enrollments.memberships.ends_at < Time.zone.today }; end
    def current
      where { enrollments.memberships.starts_at <= Time.zone.today &&
        enrollments.memberships.ends_at >= Time.zone.today }
    end
    def future; where { enrollments.memberships.starts_at > Time.zone.today }; end
    def prospective; where { enrollments.memberships.ends_at > Time.zone.today }; end
    def requestable
      Committee.requestable.select('DISTINCT committees.*').joins(:positions).
      merge( Position.requestable_by_committee.
        with_status( @association.owner.status ) )
    end
  end
  has_many :authorities, :through => :committees do
    def prospective
      where { committees.enrollments.memberships.ends_at > Time.zone.today }
    end
    def authorized( votes = 1 )
      prospective.where { committees.enrollments.votes >= my { votes } }
    end
  end
  has_many :designees, :inverse_of => :user
  has_many :requests, :inverse_of => :user
  has_many :sponsorships, :inverse_of => :user
  has_many :motions, :through => :sponsorships
  has_many :answers, :through => :requests
  has_many :periods, :through => :memberships
  has_many :positions, :through => :memberships do
    def current
      scoped.where(
        'memberships.starts_at <= :d AND memberships.ends_at >= :d',
        { :d => Time.zone.today }
      )
    end
    def requestable
      Position.requestable.with_status( @association.owner.status )
    end
  end

  scope :interested_in, lambda { |membership|
    select('DISTINCT users.*').joins(:requests).merge(
      Request.unscoped.active.interested_in( membership )
    )
  }
  scope :renewable_to, lambda { |membership|
    select('DISTINCT users.*').joins(:memberships).merge( Membership.unscoped.renewable_to( membership ) )
  }
  scope :renewal_unconfirmed, lambda {
    joins( :memberships ).merge( Membership.unscoped.joins( :period ).renewal_unconfirmed )
  }
  scope :name_like, lambda { |name|
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

  # TODO: deprecated by ransack
  #search_methods :name_like

  mount_uploader :resume, UserResumeUploader

  acts_as_authentic do |c|
    c.login_field :net_id
  end

  validates_presence_of :net_id
  validates_uniqueness_of :net_id
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email
  validates_date :date_of_birth, :allow_nil => true, :allow_blank => true
  validates_datetime :renewal_checkpoint
  validates_integrity_of :resume
  validate do |user|
    if user.resume.present? && user.resume.size > 1.megabyte
      errors.add :resume, 'file size is large than the permitted 1 megabyte'
    end
  end

  accepts_nested_attributes_for :memberships

  before_validation :import_ldap_attributes, :initialize_password, :on => :create
  before_validation { |r| r.renewal_checkpoint ||= Time.zone.now unless r.persisted? }

  # Where necessary, provide for admin to get listing of all authorities
  def allowed_authorities( votes = 1 )
    return Authority.all if role_symbols.include? :admin
    authorities.authorized votes
  end

  def authorized_position_ids(votes = 1)
    return [] if authorities.authorized(votes).empty?
    Position.where( :authority_id.in => authorities.authorized( votes ).map(&:id) ).
      select('positions.id').map(&:id)
  end

  def authorized_committee_ids(votes = 1)
    return [] if authorities.authorized(votes).empty?
    Committee.joins(:positions).merge(
      Position.where( :authority_id.in => authorities.authorized( votes ).map(&:id) ) ).
      select( 'DISTINCT committees.id' ).map(&:id)
  end

  def requestable_committees
    message = "requestable_committees is deprecated and will be removed.  " +
      "Use committees.requestable instead."
    ActiveSupport::Deprecation.warn( message )
    committees.requestable
  end

  def requestable_positions
    message = "requestable_positions is deprecated and will be removed.  " +
      "Use positions.requestable instead."
    ActiveSupport::Deprecation.warn( message )
    positions.requestable
  end

  def requestables(reload=false)
    @requestables = nil if reload
    return @requestables if @requestables
    @requestables = requests.map { |request| request.requestable }
  end

  def role_symbols
    return @role_symbols if @role_symbols
    @role_symbols ||= [:user]
    @role_symbols << :admin if admin?
    @role_symbols << :authority if authorities.any?
    @role_symbols
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

  def mobile_phone
    return super if super.blank?
    super.to_phone :pretty
  end

  def home_phone
    return super if super.blank?
    super.to_phone :pretty
  end

  def work_phone
    return super if super.blank?
    super.to_phone :pretty
  end

  protected

  def memberships_scope(tense = nil)
    scope = Membership.unscoped.where( :user_id => id )
    tense.blank? ? scope : scope.send( tense )
  end

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

