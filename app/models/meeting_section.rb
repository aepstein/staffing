class MeetingSection < ActiveRecord::Base
  attr_accessible :name, :position, :meeting_items_attributes, :_destroy

  belongs_to :meeting, inverse_of: :meeting_sections

  has_many :meeting_items, inverse_of: :meeting_section, dependent: :destroy
  has_many :motions, through: :meeting_items

  accepts_nested_attributes_for :meeting_items, allow_destroy: true

  default_scope order { [ meeting_id, position ] }

  validates :meeting, presence: true
  validates :name, presence: true, uniqueness: { scope: :meeting_id }
  validates :position, presence: true, numericality: { greater_than: 0 }
end

