class Committee < ActiveRecord::Base
  has_many :positions
  has_many :authorities, :through => :positions
  has_many :schedules, :through => :positions

  validates_presence_of :name
end

