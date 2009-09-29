class User < ActiveRecord::Base
  has_and_belongs_to_many :qualifications
  has_and_belongs_to_many :authorities
  has_many :memberships
  has_many :requests
  has_many :terms, :through => :memberships
  has_many :positions, :through => :memberships
end

