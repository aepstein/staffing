class Committee < ActiveRecord::Base
  has_many :enrollments
  has_many :positions, :through => :enrollments

  validates_presence_of :name
end

