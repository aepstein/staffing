class Position < ActiveRecord::Base
  default_scope order( 'positions.name ASC' )

  belongs_to :authority
  belongs_to :quiz
  belongs_to :schedule

  has_and_belongs_to_many :qualifications
  has_many :memberships, :dependent => :destroy do
    # Repopulate for a period
    def repopulate_unassigned_for_period!( period )
      unassigned.where( :period_id => period.id ).delete_all
      populate_unassigned_for_period!( period )
    end
    # Create vacant memberships for all periods
    def populate_unassigned!
      proxy_owner.periods.each { |p| populate_unassigned_for_period! p }
    end
    # Create vacant memberships
    def populate_unassigned_for_period!( period )
      return unless proxy_owner.schedule.periods.include? period
      previous_vacancies = nil
      memberships = vacancies_for_period( period ).inject([]) do |memo, point|
        if previous_vacancies.nil?
          point.last.times { memo << start_unassigned( point.first, period ) }
        elsif previous_vacancies < point.last
          (point.last - previous_vacancies).times { memo << start_unassigned(point.first, period) }
        elsif previous_vacancies > point.last
          (previous_vacancies - point.last).times { memo.pop.save! }
        end
        memo.each { |membership| membership.ends_at = point.first }
        previous_vacancies = point.last
        memo
      end
      memberships.each { |membership| membership.save! }
    end
    # Spaces for period
    def vacancies_for_period( period )
      Membership.concurrent_counts( period, proxy_owner.id )
    end
    private
    def start_unassigned(starts_at, period)
      build(:starts_at => starts_at, :period => period)
    end
  end
  has_many :requests, :as => :requestable
  has_many :users, :through => :memberships
  has_many :periods, :through => :schedule
  has_many :answers, :through => :requests
  has_many :enrollments, :dependent => :destroy do
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
  has_many :committees, :through => :enrollments

  scope :with_status, lambda { |status|
    where( "(positions.statuses_mask & " +
      "#{status.nil? ? 0 : 2**User::STATUSES.index(status.to_s)}) " +
      "> 0 OR positions.statuses_mask = 0" )
  }
  scope :notifiable, where( :notifiable => true )
  scope :requestable, where( :requestable => true )
  scope :unrequestable, where( :requestable => false )
  scope :renewable, where( :renewable => true )
  scope :unrenewable, where( :renewable => false )
  scope :requestable_by_committee_equals, lambda { |v|
    where( :requestable_by_committee => v )
  }

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :authority
  validates_presence_of :quiz
  validates_presence_of :schedule
  validates_numericality_of :slots, :only_integer => true, :greater_than => 0

  after_create { |r| r.memberships.populate_unassigned! }
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

  def to_s; name; end

  private

  def repopulate_slots!
    return unless schedule_id_previously_changed? || slots_previously_changed?
    if schedule_id_previously_changed? || ( slots_previously_changed? && slots_previously_was > slots )
      memberships.unassigned.delete_all
    end
    memberships.populate_unassigned!
  end

end

