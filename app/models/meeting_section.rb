class MeetingSection < ActiveRecord::Base
  PERMITTED_ATTRIBUTES = [ :id, :_destroy, :name, :position,
    meeting_items_attributes: MeetingItem::PERMITTED_ATTRIBUTES ]

  belongs_to :meeting, inverse_of: :meeting_sections

  has_many :meeting_items, inverse_of: :meeting_section, dependent: :destroy
  has_many :motions, through: :meeting_items

  accepts_nested_attributes_for :meeting_items, allow_destroy: true

  default_scope { order { [ meeting_id, position ] } }

  validates :meeting, presence: true
  validates :name, presence: true, uniqueness: { scope: :meeting_id }
  validates :position, presence: true, numericality: { greater_than: 0 }

  def to_s; new_record? ? "New Meeting Section" : name; end
end

