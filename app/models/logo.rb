class Logo < ActiveRecord::Base
  attr_accessible :name, :vector

  default_scope order( 'logos.name ASC' )

  mount_uploader :vector, VectorUploader

  has_many :committees, :dependent => :nullify, :inverse_of => :logo

  validates :name, :presence => true, :uniqueness => true
  validates :vector, :presence => true
  validates_integrity_of :vector

  def name(style=nil)
    case style
    when :file
      self.name.strip.downcase.gsub(/[^a-z]/,'-').squeeze('-')
    else
      read_attribute(:name)
    end
  end

end

