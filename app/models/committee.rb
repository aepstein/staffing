class Committee < ActiveRecord::Base
  default_scope :order => 'committees.name ASC'

  has_many :requests, :as => :requestable
  has_many :enrollments
  has_many :positions, :through => :enrollments

  validates_presence_of :name
  validates_uniqueness_of :name

  def to_s; name; end
end

