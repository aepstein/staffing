class User < ActiveRecord::Base
  include Notifiable
  notifiable_events :renew

  STATUSES = %w( staff faculty undergrad grad alumni temporary )
  ADMIN_UPDATABLE = [ :net_id, :admin, :status ]

  attr_accessible :first_name, :middle_name, :last_name, :email, :mobile_phone,
    :work_phone, :home_phone, :work_address, :date_of_birth, :resume,
    :renewal_checkpoint, :memberships_attributes

  default_scope order( 'users.last_name ASC, users.first_name ASC, users.middle_name ASC' )

  has_and_belongs_to_many :qualifications
  has_many :memberships, :inverse_of => :user do
    # Return memberships a user is authorized to review
    # User must have voting membership with future end date in committee of
    # authority for the position of the membership which overlaps the membership's
    # duration
    def authorized
      Membership.authorized_user_id_equals proxy_owner.id
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
  end

  scope :renewable_to, lambda { |membership|
    joins(:memberships).merge( Membership.unscoped.renewable_to( membership ) )
  }
  scope :no_renew_notice_since, lambda { |checkpoint|
    t = arel_table
    where( t[:renew_notice_at].eq( nil ).or( t[:renew_notice_at].lt( checkpoint ) ) )
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

  search_methods :name_like

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
  validates_datetime :renewal_checkpoint

  accepts_nested_attributes_for :memberships

  before_validation :import_ldap_attributes, :initialize_password, :on => :create
  before_validation { |r| r.renewal_checkpoint ||= Time.zone.now unless r.persisted? }

  def authority_ids( membership_constraints = { } )
    authorities( membership_constraints ).map(&:id)
  end

  # A users authorities are:
  #  * associated with a committee of which the user is a current or future member
  def authorities( membership_constraints = { } )
    return [] unless persisted?
    Authority.scoped &
    committees(:current_or_future).where( :enrollments => { :votes.gt => 0 } )
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
      select( 'DISTINCT committees.id' ) ).map(&:id)
  end

  def requestable_committees
    Committee.requestable.select('DISTINCT committees.*').joins(:positions) & Position.requestable_by_committee.with_status( status )
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

  def enrollments(tense = nil)
    Enrollment.joins(:memberships) & memberships_scope(tense)
  end

  def committees(tense = nil)
    Committee.joins(:enrollments) & Enrollment.unscoped.joins(:memberships) & memberships_scope(tense)
  end

  def current_enrollments
    enrollments :current
  end

  def past_enrollments
    enrollments :past
  end

  def future_enrollments
    enrollments :future
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

