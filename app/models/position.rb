class Position < ActiveRecord::Base
  attr_accessible :authority_id, :quiz_id, :schedule_id, :slots, :name,
    :join_message, :leave_message, :statuses, :renewable, :notifiable,
    :designable, :active, :reject_message, :enrollments_attributes,
    :minimum_slots

  default_scope lambda { ordered }

  belongs_to :authority, inverse_of: :positions
  belongs_to :quiz, inverse_of: :positions
  belongs_to :schedule, inverse_of: :positions

  has_many :memberships, inverse_of: :position, dependent: :destroy do

    # Repopulate for a period
    def repopulate_unassigned_for_period!( period )
      unassigned.where( period_id: period.id ).delete_all
      populate_unassigned_for_period! period
    end

    # Create vacant memberships for all periods
    def populate_unassigned!
      proxy_association.owner.periods.each { |p| populate_unassigned_for_period! p }
    end

    # Create vacant memberships
    def populate_unassigned_for_period!( period )
      unless proxy_association.owner.schedule.periods.include? period
        raise ArgumentError, "Period must be in current schedule"
      end
      memberships = vacancies_for_period( period ).inject([]) do |memo, point|
        if memo.length < point.last
          (point.last - memo.length).times { memo << start_unassigned(point.first, period) }
        elsif memo.length > point.last
          [memo.length, (memo.length - point.last)].min.times { memo.pop.save! validate: false }
        end
        memo.each { |membership| membership.ends_at = point.first }
        memo
      end
      # Save without validation -- method should produce valid memberships
      memberships.each { |membership| membership.save! validate: false }
    end

    # Spaces for period
    def vacancies_for_period( period )
      Membership.concurrent_counts( period, proxy_association.owner.id ).
        map { |r| [r.first, ( proxy_association.owner.minimum_slots - r.last )] }
    end

    def build_for_authorization
      build do |membership|
        membership.period ||= proxy_association.owner.schedule.periods.active
        membership.period ||= proxy_association.owner.schedule.periods.first
        if membership.period
          membership.starts_at ||= membership.period.starts_at
          membership.ends_at ||= membership.period.ends_at
        end
      end
    end

    private

    def start_unassigned(starts_at, period)
      build do |membership|
        membership.starts_at = starts_at
        membership.period = period
      end
    end
  end
  has_many :users, through: :memberships do
    def assignable; User.assignable_to(proxy_association.owner); end
  end
  has_many :periods, through: :schedule
  has_many :answers, through: :membership_requests
  has_many :authorized_enrollments, through: :authority
  has_many :enrollments, inverse_of: :position, dependent: :destroy do
    def for_committee(committee)
      self.select { |enrollment| enrollment.committee_id == committee.id }
    end
    def committees
      self.map { |enrollment| enrollment.committee.to_s }.join(', ')
    end
    def titles_for_committee(committee)
      for_committee(committee).map { |e| e.title }.join(', ')
    end
    def votes_for_committee(committee)
      for_committee(committee).inject(0) { |sum, e| sum + e.votes }
    end
  end
  has_many :committees, through: :enrollments
  has_many :requestable_enrollments, class_name: 'Enrollment',
    conditions: { requestable: true }
  has_many :requestable_committees, through: :requestable_enrollments,
    source: :committee, conditions: { active: true }
  has_many :membership_requests, include: :user, through: :requestable_committees,
    conditions: "enrollments.position_id IN " +
      "(SELECT positions.id FROM positions WHERE ( positions.statuses_mask = 0 OR " +
      "(positions.statuses_mask & users.statuses_mask) > 0 ) AND " +
      "(positions.active = #{connection.quote true}) )"

  accepts_nested_attributes_for :enrollments, allow_destroy: true

  scope :ordered, order { name }
  scope :with_status, lambda { |status|
    where( "(positions.statuses_mask & " +
      "#{status.nil? ? 0 : 2**User::STATUSES.index(status.to_s)}) " +
      "> 0 OR positions.statuses_mask = 0" )
  }
  scope :assignable_to, lambda { |user| with_status(user.status).active }
  scope :notifiable, where( notifiable: true )
  scope :renewable, where( renewable: true )
  scope :unrenewable, where( renewable: false )
  scope :designable, where( designable: true )
  scope :active, where( active: true )
  scope :inactive, where { active.not_eq( true ) }
  # Other positions that are enrolled in exactly the same committees as this
  # * presume same position means same committees
  # * presume different position means different committees if other position has no commmittees
  # * otherwise, must have all the committees the other position has and no committees
  #   other position does not have
  scope :equivalent_committees_with, lambda { |position|
    where( "positions.id = :id OR (:length > 0 AND " +
    "(SELECT COUNT( DISTINCT committee_id ) FROM enrollments WHERE " +
    "committee_id IN (:ids) AND position_id = positions.id) = :length AND " +
    "(SELECT COUNT( committee_id ) FROM enrollments WHERE " +
    "committee_id NOT IN (:ids) AND position_id = positions.id) = 0)",
    { id: position.id, ids: position.committee_ids, length: position.committees.length } )
  }

  validates :name, presence: true, uniqueness: true
  validates :authority, presence: true
  validates :quiz, presence: true
  validates :schedule, presence: true
  validates :slots, numericality: { only_integer: true, greater_than: 0 }
  validates :minimum_slots, presence: true,
    numericality: { only_integer: true, less_than_or_equal_to: :slots,
      if: :slots? }

  after_create :populate_slots!
  after_update :repopulate_slots!

  def current_emails
    memberships.assigned.current.all(include: [ :user ]).map { |membership| membership.user.email }
  end

  def statuses=(statuses)
    self.statuses_mask = (statuses & User::STATUSES).map { |status| 2**User::STATUSES.index(status) }.sum
  end

  def statuses
    User::STATUSES.reject { |status| ((statuses_mask || 0) & 2**User::STATUSES.index(status)).zero? }
  end

  def name(style=nil)
    case style
    when :file
      self.name.strip.downcase.gsub(/[^a-z]/,'-').squeeze('-')
    else
      read_attribute(:name)
    end
  end

  def inactive?; !active?; end

  def to_s; name; end

  private

  def populate_slots!
    memberships.populate_unassigned! if active?
    true
  end

  # Delete unassigned memberships if:
  # * activity status changes
  # * schedule changes
  # * number of minimum_slots is decreased
  # Populate new memberships if position is active
  def repopulate_slots!
    return true unless active_changed? || schedule_id_changed? || minimum_slots_changed?
    if ( active_changed? && inactive? ) || schedule_id_changed? ||
        ( minimum_slots_changed? && minimum_slots_was > minimum_slots )
      memberships.unassigned.delete_all
    end
    populate_slots!
  end

end

