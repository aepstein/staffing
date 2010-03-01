class Committee < ActiveRecord::Base
  default_scope :order => 'committees.name ASC'

  named_scope :requestable, { :conditions => { :requestable => true } }
  named_scope :unrequestable, { :conditions => { :requestable => false } }

  has_many :requests, :as => :requestable
  has_many :enrollments
  has_many :positions, :through => :enrollments

  validates_presence_of :name
  validates_uniqueness_of :name

  def to_s; name; end
end

