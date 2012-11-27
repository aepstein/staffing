class Meeting < ActiveRecord::Base
  attr_accessible :period_id, :committee_id, :audio, :editable_minutes,
    :published_minutes, :starts_at, :ends_at, :location, :published,
    :meeting_motions_attributes
  attr_readonly :period_id, :committee_id

  belongs_to :committee, inverse_of: :meetings
  belongs_to :period, inverse_of: :meetings

  has_many :meeting_motions, inverse_of: :meeting, dependent: :destroy
  has_many :meeting_sections, inverse_of: :meeting, dependent: :destroy
  has_many :motions, through: :meeting_motions do
    # Allowed motions are in same committee and period as the meeting
    def allowed
      return [] unless proxy_association.owner.committee && proxy_association.owner.period_id?
      proxy_association.owner.committee.motions.where(
        period_id: proxy_association.owner.period_id )
    end
  end

  mount_uploader :audio, MeetingAudioUploader
  mount_uploader :editable_minutes, MeetingEditableMinutesUploader
  mount_uploader :published_minutes, MeetingPublishableMinutesUploader

  accepts_nested_attributes_for :meeting_motions,
    reject_if: proc { |a| a['motion_name'].blank? },
    allow_destroy: true

  validates :committee, presence: true
  validates :period, presence: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true, timeliness: { after: :starts_at }
  validates :location, presence: true
  validate :period_must_be_in_committee_schedule, :must_be_in_period

  default_scope order { starts_at.desc }

  scope :past, lambda { where { ends_at < Time.zone.today.to_time } }
  scope :future, lambda { where {
    starts_at > ( Time.zone.today.to_time + 1.day ) } }
  scope :current, lambda { where { (starts_at >= Time.zone.today.to_time) &
    ( ends_at <= ( Time.zone.today.to_time + 1.day ) ) } }

  def tense
    return nil unless starts_at && ends_at
    return :past if ends_at < Time.zone.today
    return :future if starts_at > Time.zone.today
    :current
  end

  def to_s(style=nil)
    case style
    when :file
      if starts_at && committee
        "#{starts_at.to_s :number}-#{committee.to_s :file}"
      end
    when :editable_minutes_file
      "#{@meeting.to_s :file}-editable_minutes.#{@meeting.editable_minutes.extension}"
    when :published_minutes_file
      "#{@meeting.to_s :file}-published_minutes.#{@meeting.published_minutes.extension}"
    when :audio_file
      "#{@meeting.to_s :file}-audio.#{@meeting.audio.extension}"
    else
      return starts_at.to_s :us_ordinal if starts_at?
    end
    super
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

