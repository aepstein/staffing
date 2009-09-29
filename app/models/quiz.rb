class Quiz < ActiveRecord::Base
  has_many :positions
  has_many :committees, :through => :positions
  has_many :authorities, :through => :positions
  has_many :schedules, :through => :positions

  validates_presence_of :name
end

