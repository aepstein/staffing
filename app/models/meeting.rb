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
  validates_presence_of :when_scheduled
  validate :period_must_be_in_committee_schedule, :when_scheduled_must_be_in_period

  private

  def period_must_be_in_committee_schedule
    return unless committee && period
    errors.add :period, "is not in schedule for #{committee}" unless committee.schedule.periods.include? period
  end

  def when_scheduled_must_be_in_period
    return unless when_scheduled && period
    errors.add :when_scheduled, "is not within #{period}" unless period.starts_at <= when_scheduled && period.ends_at >= when_scheduled
  end

end

