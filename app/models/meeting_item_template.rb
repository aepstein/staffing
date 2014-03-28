class MeetingItemTemplate < ActiveRecord::Base
  PERMITTED_ATTRIBUTES = [ :id, :_destroy, :description, :duration, :name,
    :meeting_section_template_id, :position ]
  attr_readonly :meeting_section_template_id

  belongs_to :meeting_section_template, inverse_of: :meeting_item_templates

  validates :name, presence: true,
    uniqueness: { scope: :meeting_section_template_id }
  validates :meeting_section_template, presence: true
  validates :duration, numericality: { greater_than: 0, allow_blank: true }
  validates :position, presence: true, numericality: { greater_than: 0 }

  before_validation do |template|
    template.duration = nil if template.duration.blank?
  end

  default_scope { order { [ meeting_section_template_id, position ] } }

  def populable_attributes
    { name: name, duration: duration, description: description,
      position: position }
  end

  def to_s
    if new_record?
      "New Meeting Item Template"
    elsif name?
      name
    else
      super
    end
  end
end

