class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :period
  belongs_to :position
  belongs_to :request
  has_many :designees, :dependent => :delete_all do
    def populate
      return Array.new unless proxy_owner.position
      proxy_owner.position.committees.inject([]) do |memo, committee|
        memo << build(:committee => committee) unless committee_ids.include? committee.id
        memo
      end
    end
    protected
    def committee_ids
      self.map { |designee| designee.committee_id }.uniq
    end
  end

  default_scope includes(:user,:period).order(
    "memberships.ends_at DESC, memberships.starts_at DESC, " +
    "users.last_name ASC, users.first_name ASC, users.middle_name ASC"
  )
  scope :assigned, where( :user_id => nil )
  scope :unassigned, where( :user_id.ne => nil )
  scope :requested, where( :request_id.ne => nil )
  scope :unrequested, where( :request_id => nil )
  scope :current, where( :starts_at.lte => Time.zone.today, :ends_at.gte => Time.zone.today )
  scope :future, where( :starts_at.gt => Time.zone.today )
  scope :past, where( :ends_at.lt => Time.zone.today )
  scope :renewable, lambda { joins(:position) & Position.renewable }
  scope :unrenewable, lambda { joins(:position) & Position.unrenewable }
  scope :overlap, lambda { |starts, ends| where( :starts_at.lte => ends, :ends_at.gte => starts) }
  scope :pending_renewal_within, lambda { |starts, ends|
    renewable.unrenewed.where( :starts_at.gte => starts, :ends_at.lte => ends)
  }
  scope :join_notice_pending, lambda { notifiable.current.where(:join_notice_sent_at => nil) }
  scope :leave_notice_pending, lambda { notifiable.past.where(:leave_notice_sent_at => nil) }

  scope :notifiable, includes(:position).where( :user_id.ne => nil ) & Position.notifiable
  scope :renewed, joins("INNER JOIN memberships AS renewable_memberships ON " +
        " memberships.user_id = renewable_memberships.user_id AND " +
        " memberships.position_id = renewable_memberships.position_id AND " +
        " #{date_add :ends_at, 1.day} = #{date_add 'renewable_memberships.starts_at', 0.days}")
  scope :unrenewed, joins("LEFT JOIN memberships AS renewable_memberships ON " +
        " memberships.user_id = renewable_memberships.user_id AND " +
        " memberships.position_id = renewable_memberships.position_id AND " +
        " #{date_add :ends_at, 1.day} = #{date_add 'renewable_memberships.starts_at', 0.days}").
        where( 'renewable_memberships.id IS NULL' )
  scope :confirmed, includes(:request).where(
    'memberships.confirmed_at IS NOT NULL AND ' +
    '( requests.updated_at IS NULL OR ' +
    ' requests.updated_at <= memberships.confirmed_at )'
  )
  scope :unconfirmed, includes(:request).where(
    'memberships.confirmed_at IS NULL OR ' +
    '(requests.updated_at IS NOT NULL AND requests.updated_at > memberships.confirmed_at)'
  )
  scope :user_name_like, lambda { |text| joins(:user) & User.name_like(text) }
  scope :enrollments_committee_id_equals, lambda { |committee_id|
    joins('INNER JOIN enrollments ON enrollments.position_id = memberships.position_id').where(
      'enrollments.position_id = memberships.position_id ' +
      'AND enrollments.committee_id = ?', committee_id
    )
  }

  attr_accessor :starts_at_previously_changed, :ends_at_previously_changed,
    :period_id_previously_changed, :period_id_previously_was,
    :ends_at_previously_was, :starts_at_previously_was
  alias :starts_at_previously_changed? :starts_at_previously_changed
  alias :ends_at_previously_changed? :ends_at_previously_changed
  alias :period_id_previously_changed? :period_id_previously_changed

  delegate :enrollments, :to => :position

  accepts_nested_attributes_for :designees, :reject_if => proc { |a| a['user_name'].blank? }, :allow_destroy => true

  validates_presence_of :period
  validates_presence_of :position
  validates_date :starts_at
  validates_date :ends_at
  validate :concurrent_memberships_must_not_exceed_slots, :must_be_within_period, :user_must_be_qualified

  before_validation { |r| r.designees.each { |d| d.membership = r } }
  after_save :repopulate_unassigned, :claim_request!
  after_destroy :repopulate_unassigned

  # The notice_type should be (join|leave)
  def send_notice!(notice_type)
    MembershipMailer.send "deliver_#{notice_type}_notice", self
    self.send "#{notice_type}_notice_sent_at=", Time.zone.now
    save!
  end

  def confirmed?
    return false unless confirmed_at?
    return request.updated_at < confirmed_at if request
    true
  end

  def unconfirmed?; !confirmed?; end

  def confirm
    self.confirmed_at = Time.zone.now
    save
  end

  def user_name
    "#{user.name} (#{user.net_id})" if user
  end

  def user_name=(name)
    if name.to_net_ids.empty?
      self.user = User.find_by_net_id name[/\(([^\s]*)\)/,1]
    else
      self.user = User.find_or_create_by_net_id name.to_net_ids.first
    end
    self.user = nil if user && user.id.nil?
  end

  # Returns the context in which this membership should be framed (useful for polymorphic_path)
  def context
    request || position || raise( "No context is possible" )
  end

  def user_must_be_qualified
    return unless user && position
    if (position.qualification_ids - user.qualification_ids).size > 0
      errors.add :user, "is not qualified for position"
    end
  end

  def must_be_within_period
    period(true) if period && period_id && period.id != period_id
    if starts_at && ends_at && ends_at < starts_at
      errors.add :ends_at, "must be at or after #{starts_at.to_s :rfc822}"
    end
    if starts_at && period && period.starts_at > starts_at
      errors.add :starts_at, "must be within #{period}"
    end
    if ends_at && period && period.ends_at < ends_at
      errors.add :ends_at, "must be within #{period}"
    end
  end

  def concurrent_membership_counts
    scope = Membership.where( :position_id => position_id )
    scope = scope.where( :id.ne => id ) unless new_record? # exclude this record
    scope = scope.assigned if user # unassigned will be regenerated anyways
    position.memberships.edges_for(self).inject({}) do |memo, date|
      memo[date] = scope.overlap( date, date ).count
      memo[date] += 1 if starts_at <= date && ends_at >= date
      memo
    end
  end

  def concurrent_memberships_must_not_exceed_slots
    return unless starts_at && ends_at && position
    if position.slots < concurrent_membership_counts.values.sort.last
      errors.add :base, "lacks free slots for the specified time period"
    end
  end

  def request_id=(new_id)
    self.request = Request.find(new_id) if new_id && ( request.nil? || request.id != new_id.to_i )
    write_attribute(:request_id, new_id)
  end

  def request_with_population=(new_request)
    return if new_request.nil?
    self.position = new_request.requestable if new_request.requestable.class == Position
    self.period ||= position.periods.overlaps(new_request.starts_at, new_request.ends_at).last if position
    if !period.blank? && user.blank?
      self.starts_at ||= ( period.starts_at > new_request.starts_at ? period.starts_at : new_request.starts_at )
      self.ends_at ||= ( period.ends_at < new_request.ends_at ? period.ends_at : new_request.ends_at )
    end
    self.user = new_request.user
    self.request_without_population = new_request
  end

  def renew_until
    return unless request && request.ends_at > ends_at
    request.ends_at
  end

  alias_method_chain :request=, :population

  def description
    return request.requestable.to_s if request
    return position.requestables.first.to_s unless position.requestables.empty?
    position.to_s
  end

  def to_s; "#{position} (#{starts_at.to_s :rfc822} - #{ends_at.to_s :rfc822})"; end

  protected

  def claim_request!
    return if self.request || user.nil?
    request = nil
    if position.requestable?
      request = user.requests.where(:requestable_type => 'Position', :requestable_id => position.id ).first
    end
    unless request || position.committee_ids.empty?
      request = user.requests.where(:requestable_type => 'Committee', :requestable_id.in => position.committee_ids ).first
    end
    request.memberships << self unless request.blank?
  end

  def repopulate_unassigned
    # Only necessary if this is an assigned shift and a timing-related parameter changed
    return unless user && ( period_id_previously_changed? || starts_at_previously_changed? || ends_at_previously_changed? || destroyed? )
    # Eliminate unassigned shifts in the new period for this shift
    periods = position.schedule.periods.overlaps( starts_at, ends_at ).to_a
    periods.each do |p|
      position.memberships.unassigned.where( :period_id => p.id ).delete_all
    end
    # Fill unassigned shifts for current and previous unfilled period
    unless starts_at_previously_was.blank? || ends_at_previously_was.blank?
      periods += position.schedule.periods.overlaps( starts_at_previously_was, ends_at_previously_was ).to_a
    end
    periods.uniq.each do |p|
      position.memberships(true).populate_unassigned_for_period p
    end
  end

end

