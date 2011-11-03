class Brand < ActiveRecord::Base
  attr_accessible :name, :logo

  default_scope order( 'brands.name ASC' )

  mount_uploader :logo, VectorUploader

  has_many :committees, dependent: :nullify, inverse_of: :brand

  validates :name, presence: true, uniqueness: true
  validates :logo, presence: true, integrity: true

  def name(style=nil)
    case style
    when :file
      self.name.strip.downcase.gsub(/[^a-z]/,'-').squeeze('-')
    else
      read_attribute(:name)
    end
  end

  def to_s(style=nil); name(style); end

end

