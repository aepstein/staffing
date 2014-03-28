class Brand < ActiveRecord::Base
  CONTACT_ATTRIBUTES = [ :phone, :fax, :email, :web, :address_1, :address_2,
    :city, :state, :zip ]

  default_scope { order( 'brands.name ASC' ) }

  mount_uploader :logo, VectorUploader

  has_many :committees, dependent: :nullify, inverse_of: :brand

  validates :name, presence: true, uniqueness: true
  validates :logo, presence: true, integrity: true

  # Default system-wide contact attributes
  def self.contact_attributes
    defaults = Staffing::Application.app_config['defaults']['contact']
    CONTACT_ATTRIBUTES.inject({}) do |memo, attribute|
      memo[ attribute ] = defaults[ attribute.to_s ] unless defaults[ attribute.to_s ].blank?
      memo
    end
  end

  # Brand-specific contact attributes
  def contact_attributes
    CONTACT_ATTRIBUTES.inject({}) do |memo, attribute|
      memo[ attribute ] = send( attribute ) unless send( attribute ).blank?
      memo
    end
  end

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

