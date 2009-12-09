class Quiz < ActiveRecord::Base
  has_many :positions
  has_many :enrollments, :through => :positions
  has_many :authorities, :through => :positions
  has_many :schedules, :through => :positions

  validates_presence_of :name
  validates_uniqueness_of :name
end

