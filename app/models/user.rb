class User < ActiveRecord::Base
  default_scope :order => 'users.last_name ASC, users.first_name ASC, users.middle_name ASC'

  attr_protected :admin, :net_id

  has_and_belongs_to_many :qualifications
  has_and_belongs_to_many :authorities
  has_many :memberships
  has_many :requests
  has_many :periods, :through => :memberships
  has_many :positions, :through => :memberships

  acts_as_authentic do |c|
    c.login_field :net_id
  end

  scope_procedure :name_like, lambda { |name| first_name_or_last_name_or_middle_name_or_net_id_like( name ) }

  validates_presence_of :net_id
  validates_uniqueness_of :net_id
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email
  validates_date :date_of_birth, :allow_nil => true, :allow_blank => true

  before_validation_on_create :import_ldap_attributes, :initialize_password

  def role_symbols
    return [:admin,:user] if admin?
    [:user]
  end

  def name(style = nil)
    name = case style
    when :last_first
      "#{last_name}, #{first_name}"
    else
      "#{first_name} #{last_name}"
    end
    name.squeeze(' ').strip
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
      self.first_name = ldap_entry.first_name.titleize unless ldap_entry.first_name.nil?
      self.middle_name = ldap_entry.middle_name.titleize unless ldap_entry.middle_name.nil?
      self.last_name = ldap_entry.last_name.titleize unless ldap_entry.last_name.nil?
      self.email ||= "#{self.net_id}@cornell.edu"
      self.status = ldap_entry.status unless ldap_entry.status.nil?
      # TODO addresses and phone numbers
    else
      self.first_name ||= 'UNKNOWN'
      self.last_name ||= 'UNKNOWN'
    end
  end
end

