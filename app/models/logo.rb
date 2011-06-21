class Logo < ActiveRecord::Base
  mount_uploader :vector, VectorUploader

  validates :name, :presence => true, :uniqueness => true
  validates :vector, :presence => true
  validates_integrity_of :vector
end

