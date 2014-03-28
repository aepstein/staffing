class MeetingTemplate < ActiveRecord::Base
  has_many :committees, inverse_of: :meeting_template, dependent: :nullify
  has_many :meeting_section_templates, inverse_of: :meeting_template,
    dependent: :destroy

  accepts_nested_attributes_for :meeting_section_templates, allow_destroy: true

  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order { name } }

  def to_s; name? ? name : super; end
end

