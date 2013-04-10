class Attachment < ActiveRecord::Base
  attr_accessible :document, :document_cache, :description, :_destroy,
    as: [ :admin, :staff, :default ]
  attr_readonly :attachable_type, :attachable_id

  belongs_to :attachable, polymorphic: true

  has_paper_trail

  mount_uploader :document, DocumentUploader

  validates :attachable, presence: true
  validates :document, presence: true, integrity: true
  validates :description, presence: true,
    uniqueness: { scope: [ :attachable_id, :attachable_type ] }

  def to_s(format=nil)
    case format
    when :file
      return super() unless attachable
      ( attachable.to_s(:file) + '-' +
      description.strip.downcase.gsub(/[^a-z0-9]/,'-').squeeze('-') )[0..240] +
      File.extname( document.path )
    else
      if persisted?
        description
      else
        "New Attachment"
      end
    end
  end
end

