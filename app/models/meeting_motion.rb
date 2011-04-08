class MeetingMotion < ActiveRecord::Base
  attr_accessible :meeting_id, :motion_id, :motion_name, :comment,
    :introduced_version, :final_version
  attr_readonly :meeting_id, :motion_id, :motion_name

  belongs_to :meeting, :inverse_of => :meeting_motions
  belongs_to :motion, :inverse_of => :meeting_motions

  has_attached_file :introduced_version,
    :path => ':rails_root/db/uploads/:rails_env/meeting_motions/:id_partition/:attachment/:style.:extension',
    :url => '/system/meeting_motions/:id_partition/:attachment/:style.:extension'
  has_attached_file :final_version,
    :path => ':rails_root/db/uploads/:rails_env/meeting_motions/:id_partition/:attachment/:style.:extension',
    :url => '/system/meeting_motions/:id_partition/:attachment/:style.:extension'

  validates_presence_of :meeting
  validates_presence_of :motion
  validates_uniqueness_of :meeting_id, :scope => [ :motion_id ]
  validate :motion_must_be_allowed

  def motion_name=( name )
    return if meeting.blank?
    self.motion = meeting.motions.allowed.where(:name => name).first
  end

  def motion_name
    motion ? motion.name : nil
  end

  def motion_must_be_allowed
    return unless meeting && motion
    errors.add :motion, 'must be among allowed motions for meeting' unless meeting.motions.allowed.include? motion
  end
end

