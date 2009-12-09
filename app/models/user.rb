class User < ActiveRecord::Base
  has_and_belongs_to_many :qualifications
  has_and_belongs_to_many :authorities
  has_many :memberships
  has_many :requests
  has_many :periods, :through => :memberships
  has_many :positions, :through => :memberships

  acts_as_authentic do |c|
    c.login_field :net_id
  end

  validates_presence_of :net_id
  validates_uniqueness_of :net_id
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email
  validates_date :date_of_birth, :allow_nil => true

  def name
    "#{first_name} #{last_name}".squeeze(' ').strip
  end
end

