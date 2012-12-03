class MeetingSectionTemplate < ActiveRecord::Base
  attr_accessible :name, :meeting_template_id, :position,
    :meeting_item_templates_attributes, :_destroy
  attr_readonly :meeting_template_id

  belongs_to :meeting_template, inverse_of: :meeting_section_templates
  has_many :meeting_item_templates, inverse_of: :meeting_section_template,
    dependent: :destroy

  accepts_nested_attributes_for :meeting_item_templates, allow_destroy: true

  validates :name, presence: true, uniqueness: { scope: :meeting_template_id }
  validates :meeting_template, presence: true
  validates :position, presence: true, numericality: { greater_than: 0 }

  default_scope order { [ meeting_template_id, position ] }

  def to_s; name? ? name : super; end
end

