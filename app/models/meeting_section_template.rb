class MeetingSectionTemplate < ActiveRecord::Base
  PERMITTED_ATTRIBUTES = [ :id, :_destroy, :name, :meeting_template_id,
    :position,
    { meeting_item_templates_attributes: MeetingItemTemplate::PERMITTED_ATTRIBUTES } ]
  attr_readonly :meeting_template_id

  belongs_to :meeting_template, inverse_of: :meeting_section_templates
  has_many :meeting_item_templates, inverse_of: :meeting_section_template,
    dependent: :destroy

  accepts_nested_attributes_for :meeting_item_templates, allow_destroy: true

  validates :name, presence: true, uniqueness: { scope: :meeting_template_id }
  validates :meeting_template, presence: true
  validates :position, presence: true, numericality: { greater_than: 0 }

  default_scope { ordered }
  scope :ordered, -> { order { [ meeting_section_templates.meeting_template_id, 
    meeting_section_templates.position ] } }

  def populable_attributes
    { name: name, position: position }
  end

  def to_s
    if new_record?
      "New Meeting Section Template"
    elsif name?
      name
    else
      super
    end
  end
end

