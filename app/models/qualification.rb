class Qualification < ActiveRecord::Base
  attr_accessible :name, :description

  default_scope :order => 'qualifications.name ASC'

  has_and_belongs_to_many :positions
  has_and_belongs_to_many :users

  validates_presence_of :name
  validates_uniqueness_of :name

  def to_s; name; end
end

