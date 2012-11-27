class MeetingSection < ActiveRecord::Base
  belongs_to :meeting, inverse_of: :meeting_sections

  has_many :meeting_items, inverse_of: :meeting_section, dependent: :destroy

  acts_as_list scope: :meeting_id

  attr_accessible :name, :position

  validates :meeting, presence: true
  validates :name, presence: true, uniqueness: { scope: :meeting_id }
end

