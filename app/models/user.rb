class User < ActiveRecord::Base
  has_and_belongs_to_many :qualifications
  has_and_belongs_to_many :authorities
  has_many :memberships
  has_many :requests
  has_many :terms, :through => :memberships
  has_many :positions, :through => :memberships

  validates_presence_of :net_id
  validates_uniqueness_of :net_id
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email
  validates_date :date_of_birth, :allow_nil => true
end

