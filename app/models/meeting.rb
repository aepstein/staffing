class Meeting < ActiveRecord::Base
  attr_readonly :period_id, :committee_id

  attr_accessor :publish_to, :publish_from, :publish_note

  belongs_to :committee, inverse_of: :meetings
  belongs_to :period, inverse_of: :meetings

  has_many :enrollments, through: :committee
  has_many :meeting_sections, inverse_of: :meeting, dependent: :destroy do
    def populate
      return unless template && length == 0
      template.meeting_section_templates.each do |section_template|
        section = build( section_template.populable_attributes )
        section_template.meeting_item_templates.each do |item_template|
          section.meeting_items.build( item_template.populable_attributes )
        end
      end
    end

    def template
      proxy_association.owner.committee.meeting_template
    end
  end
  has_many :meeting_items, -> { order( 
    'meeting_sections.position, meeting_items.position' ) },
    through: :meeting_sections
  has_many :motions, through: :meeting_sections do
    # Allowed motions are in same committee and period as the meeting
    def allowed
      return [] unless proxy_association.owner.committee && proxy_association.owner.period_id?
      proxy_association.owner.committee.motions.where(
        period_id: proxy_association.owner.period_id )
    end
  end
  has_many :minute_motions, class_name: 'Motion'

  accepts_nested_attributes_for :meeting_sections, allow_destroy: true

  delegate :effective_contact_name_and_email, :effective_contact_email,
    :effective_contact_name, :users_for, to: :committee

  mount_uploader :audio, MeetingAudioUploader
  mount_uploader :editable_minutes, MeetingEditableMinutesUploader
  mount_uploader :published_minutes, MeetingPublishableMinutesUploader

  validates :committee, presence: true
  validates :period, presence: true
  validates :starts_at, presence: true
  validates :duration, presence: true, numericality: { integer_only: true, greater_than: 0 }
  validates :location, presence: true
  validate :period_must_be_in_committee_schedule, :must_be_in_period

  scope :ordered, lambda { order { starts_at.desc } }
  scope :past, lambda { where { starts_at < Time.zone.today.to_time } }
  scope :future, lambda { where {
    starts_at > ( Time.zone.today.to_time + 1.day ) } }
  scope :current, lambda { where { (starts_at >= Time.zone.today.to_time) &
    ( starts_at <= ( Time.zone.today.to_time + 1.day ) ) } }
  scope :current_period, lambda { where { period_id.in( 
    Period.current.select { id } ) } }
  scope :recent, lambda { past.current_period.ordered }

  # Extract enclosures
  def attachments(reload = false)
    return @attachments unless reload || @attachments.nil?
    @attachments = {}
    meeting_sections.each do |section|
      section.meeting_items.each do |item|
        @attachments[ item ] = item.enclosures.to_a
      end
    end
    @attachments
  end

  def attachment_index( attachment )
    attachments.values.flatten.index( attachment ) + 1
  end

  def attachment_filename( attachment )
    base = "#{attachment_index(attachment)}_#{attachment.to_s :file}"
    return "#{base}.pdf" if attachment.instance_of?( Motion ) || attachment.instance_of?( MotionCommentReport )
    base
  end

  def publish_defaults
    self.publish_to = committee.publish_email
  end

  def publish
    if publish_to
      MeetingMailer.publish_notice( self, to: publish_to, from: publish_from,
        note: publish_note ).deliver
      update_column :published, true
      true
    else
      errors.add :publish_to, 'may not be blank'
      false
    end
  end

  def reload
    @attachments = nil
    super
  end

  def ends_at
    return nil unless starts_at && duration
    starts_at + duration.minutes
  end

  def tense
    return nil unless starts_at
    return :past if starts_at < Time.zone.today
    return :future if starts_at > Time.zone.today
    :current
  end

  def to_json_attributes
    { :id => "meeting-#{id}",
      :title => committee.name,
      :start => starts_at,
      :end => ends_at,
      :url => self,
      :location => location,
      :allDay => false }
  end

  def to_s(style=nil)
    case style
    when :file
      if starts_at && committee
        return "#{starts_at.to_s :number}-#{committee.name :file}"
      end
    when :time
      return "#{starts_at.to_formatted_s(:us_time)} - #{ends_at.to_formatted_s(:us_time)}".strip
    when :editable_minutes_file
      return "#{to_s :file}-editable_minutes#{File.extname editable_minutes.path}"
    when :published_minutes_file
      return "#{to_s :file}-published_minutes#{File.extname published_minutes.path}"
    when :audio_file
      return "#{to_s :file}-audio#{File.extname audio.path}"
    else
      return starts_at.to_s :us_ordinal if starts_at?
    end
    super()
  end

  private

  def period_must_be_in_committee_schedule
    return unless committee && period
    errors.add :period, "is not in schedule for #{committee}" unless committee.schedule.periods.include? period
  end

  def must_be_in_period
    return unless starts_at && period
    errors.add :starts_at, "is not within #{period}" unless period.starts_at.to_time <= starts_at && period.ends_at.to_time >= starts_at
  end

end

