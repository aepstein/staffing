class Qualification < ActiveRecord::Base
  has_and_belongs_to_many :positions
  has_and_belongs_to_many :users

  validates_presence_of :name
end

