class Meeting < ActiveRecord::Base
  attr_accessible :period_id, :committee_id, :audio, :editable_minutes,
    :published_minutes, :starts_at, :ends_at, :location,
    :meeting_motions_attributes
  attr_readonly :period_id, :committee_id

  belongs_to :committee, :inverse_of => :meetings
  belongs_to :period, :inverse_of => :meetings

  has_many :meeting_motions, :inverse_of => :meeting, :dependent => :destroy
  has_many :motions, :through => :meeting_motions do
    # Allowed motions are in same committee and period as the meeting
    def allowed
      return [] unless proxy_owner.committee && proxy_owner.period_id?
      proxy_owner.committee.motions.where(:period_id => proxy_owner.period_id)
    end
  end

  has_attached_file :audio,
    :path => ':rails_root/db/uploads/:rails_env/meetings/:id_partition/:attachment/:style.:extension',
    :url => '/system/meetings/:id_partition/:attachment/:style.:extension'
  has_attached_file :editable_minutes,
    :path => ':rails_root/db/uploads/:rails_env/meetings/:id_partition/:attachment/:style.:extension',
    :url => '/system/meetings/:id_partition/:attachment/:style.:extension'
  has_attached_file :published_minutes,
    :path => ':rails_root/db/uploads/:rails_env/meetings/:id_partition/:attachment/:style.:extension',
    :url => '/system/meetings/:id_partition/:attachment/:style.:extension'

  accepts_nested_attributes_for :meeting_motions, :reject_if => proc { |a| a['motion_name'].blank? }, :allow_destroy => true

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

  def tense
    return nil unless starts_at && ends_at
    return :past if ends_at < Time.zone.today
    return :future if starts_at > Time.zone.today
    :current
  end

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

