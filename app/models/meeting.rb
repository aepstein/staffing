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
  validates_presence_of :starts_at
  validates_presence_of :ends_at
  validates_presence_of :location
  validates_datetime :ends_at, :after => :starts_at
  validate :period_must_be_in_committee_schedule, :must_be_in_period

  default_scope order( 'meetings.starts_at DESC' )

  scope :past, lambda { where( :ends_at.lt => Time.zone.today.to_time ) }
  scope :future, lambda { where( :starts_at.gt => (Time.zone.today.to_time + 1.day) ) }
  scope :current, lambda { where( :starts_at.gte => Time.zone.today.to_time, :ends_at.lte => ( Time.zone.today.to_time + 1.day ) ) }

  private

  def period_must_be_in_committee_schedule
    return unless committee && period
    errors.add :period, "is not in schedule for #{committee}" unless committee.schedule.periods.include? period
  end

  def must_be_in_period
    return unless starts_at && ends_at && period
    errors.add :starts_at, "is not within #{period}" unless period.starts_at.to_time <= starts_at && period.ends_at.to_time >= starts_at
    errors.add :ends_at, "is not within #{period}" unless period.starts_at.to_time <= ends_at && period.ends_at.to_time >= ends_at
  end

end

