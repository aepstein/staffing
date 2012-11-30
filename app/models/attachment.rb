class Attachment < ActiveRecord::Base
  attr_accessible :document, :document_cache, :description,
    as: [ :admin, :default ]
  attr_readonly :attachable_type, :attachable_id

  belongs_to :attachable, polymorphic: true

  has_paper_trail

  mount_uploader :document, DocumentUploader

  validates :attachable, presence: true
  validates :document, presence: true, integrity: true
  validates :description, presence: true,
    uniqueness: { scope: [ :attachable_id, :attachable_type ] }

  def to_s(format=nil)
    return super() unless attachable
    case format
    when :file
      ( attachable.to_s(:file) + '-' +
      description.strip.downcase.gsub(/[^a-z0-9]/,'-').squeeze('-') )[0..240] +
      File.extname( document.filename )
    else
      "#{attachable} #{description}"
    end
  end
end

