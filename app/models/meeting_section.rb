class MeetingSection < ActiveRecord::Base
  attr_accessible :name, :position

  belongs_to :meeting, inverse_of: :meeting_sections

  has_many :meeting_items, inverse_of: :meeting_section, dependent: :destroy
  has_many :motions, through: :meeting_items

  accepts_nested_attributes_for :meeting_items

  acts_as_list scope: :meeting_id

  validates :meeting, presence: true
  validates :name, presence: true, uniqueness: { scope: :meeting_id }
end

