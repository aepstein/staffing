class Meeting < ActiveRecord::Base
  belongs_to :committee
  belongs_to :period

  has_attached_file :audio,
    :path => ':rails_root/db/uploads/:rails_env/meetings/:id_partition/:attachment/:style.:extension',
    :url => '/system/meetings/:id_partition/:attachment/:style.:extension'
  has_attached_file :editable_minutes,
    :path => ':rails_root/db/uploads/:rails_env/meetings/:id_partition/:attachment/:style.:extension',
    :url => '/system/meetings/:id_partition/:attachment/:style.:extension'
  has_attached_file :published_minutes,
    :path => ':rails_root/db/uploads/:rails_env/meetings/:id_partition/:attachment/:style.:extension',
    :url => '/system/meetings/:id_partition/:attachment/:style.:extension'

  validates_presence_of :committee
  validates_presence_of :period
  validates_date :when_scheduled, :between => :period_range
  validate :period_must_be_in_committee_schedule

  def period_must_be_in_committee_schedule
    return unless committee && period
    errors.add :period, "is not in schedule for #{committee}" unless committee.schedule.periods.include? period
  end

  def period_range; return unless period; period.to_range; end
end

