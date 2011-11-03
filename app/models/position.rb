class Position < ActiveRecord::Base
  attr_accessible :authority_id, :quiz_id, :schedule_id, :slots, :name,
    :join_message, :leave_message, :statuses, :requestable, :renewable,
    :notifiable, :designable, :active, :requestable_by_committee,
    :reject_message

  default_scope lambda { ordered }

  belongs_to :authority, inverse_of: :positions
  belongs_to :quiz, inverse_of: :positions
  belongs_to :schedule, inverse_of: :positions

  has_and_belongs_to_many :qualifications
  has_many :memberships, inverse_of: :position, dependent: :destroy do
    # Repopulate for a period
    def repopulate_unassigned_for_period!( period )
      unassigned.where( :period_id => period.id ).delete_all
      populate_unassigned_for_period! period
    end
    # Create vacant memberships for all periods
    def populate_unassigned!
      @association.owner.periods.each { |p| populate_unassigned_for_period! p }
    end
    # Create vacant memberships
    def populate_unassigned_for_period!( period )
      raise ArgumentError, "Period must be in current schedule" unless @association.owner.schedule.periods.include? period
      previous_vacancies = nil
      memberships = vacancies_for_period( period ).inject([]) do |memo, point|
        if previous_vacancies.nil?
          point.last.times { memo << start_unassigned( point.first, period ) }
        elsif previous_vacancies < point.last
          (point.last - previous_vacancies).times { memo << start_unassigned(point.first, period) }
        elsif previous_vacancies > 0 && previous_vacancies > point.last
          (previous_vacancies - point.last).times { memo.pop.save! :validate => false }
        end
        memo.each { |membership| membership.ends_at = point.first }
        previous_vacancies = ( point.last > 0 ? point.last : 0 )
        memo
      end
      # Save without validation -- method should produce valid memberships
      memberships.each { |membership| membership.save! :validate => false }
    end
    # Spaces for period
    def vacancies_for_period( period )
      Membership.concurrent_counts( period, @association.owner.id ).map { |r| [r.first, ( @association.owner.slots - r.last )] }
    end

    private

    def start_unassigned(starts_at, period)
      membership = build
      membership.starts_at = starts_at
      membership.period = period
      membership
    end
  end
  has_many :requests, as: :requestable
  has_many :users, through: :memberships
  has_many :periods, through: :schedule
  has_many :answers, through: :requests
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

  scope :ordered, order { name }
  scope :with_enrollments, joins( "LEFT JOIN enrollments ON enrollments.position_id = positions.id" )
  scope :with_requests, lambda {
    with_enrollments.joins( "INNER JOIN requests INNER JOIN users" ).
    where("requests.user_id = users.id").
    where( Request::POSITIONS_JOIN_SQL )
  }
  scope :with_status, lambda { |status|
    where( "(positions.statuses_mask & " +
      "#{status.nil? ? 0 : 2**User::STATUSES.index(status.to_s)}) " +
      "> 0 OR positions.statuses_mask = 0" )
  }
  # Limit to positions compatible with users' status
  # * assumes a join with the users table
  scope :with_users_status, where(
   "positions.statuses_mask = 0 OR " +
   "( users.statuses_mask & positions.statuses_mask ) > 0" )
  scope :notifiable, where( :notifiable => true )
  scope :requestable, where( :requestable => true )
  scope :unrequestable, where( :requestable => false )
  scope :renewable, where( :renewable => true )
  scope :unrenewable, where( :renewable => false )
  scope :requestable_by_committee, where( :requestable_by_committee => true )
  scope :designable, where( :designable => true )
  scope :active, where( :active => true )
  scope :inactive, where { active != true }

  validates :name, :presence => true, :uniqueness => true
  validates :authority, :presence => true
  validates :quiz, :presence => true
  validates :schedule, :presence => true
  validates :slots, :numericality => { :only_integer => true, :greater_than => 0 }

  after_create :populate_slots!
  after_update :repopulate_slots!

  def current_emails
    memberships.assigned.current.all(:include => [ :user ]).map { |membership| membership.user.email }
  end

  def requestables
    return [self] if requestable?
    enrollments.map { |enrollment| enrollment.committee }.select { |committee| committee.requestable? }
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
  # * number of slots is decreased
  # Populate new memberships if position is active
  def repopulate_slots!
    return true unless schedule_id_changed? || slots_changed?
    if active_changed? || schedule_id_changed? || ( slots_changed? && slots_was > slots )
      memberships.unassigned.delete_all
    end
    populate_slots!
  end

end

