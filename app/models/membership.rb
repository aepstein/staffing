class Membership < ActiveRecord::Base
  notifiable_events :join, :leave

  RENEWABLE_ATTRIBUTES = [ :renew_until, :renewal_confirmed_at ]
  UPDATABLE_ATTRIBUTES = [ :user_name, :user_id, :period_id, :position_id,
    :request_id, :starts_at, :ends_at, :designees_attributes,
    :designees_attributes ]
  attr_accessible RENEWABLE_ATTRIBUTES, :as => :default
  attr_accessible RENEWABLE_ATTRIBUTES, UPDATABLE_ATTRIBUTES, :as => :updator

  attr_readonly :position_id

  include UserNameLookup

  belongs_to :user, :inverse_of => :memberships
  belongs_to :period, :inverse_of => :memberships
  belongs_to :position, :inverse_of => :memberships
  belongs_to :request, :inverse_of => :memberships
  belongs_to :renewed_by_membership, :class_name => 'Membership',
    :inverse_of => :renewed_memberships
  has_many :enrollments, :primary_key => :position_id,
    :foreign_key => :position_id
  has_many :renewed_memberships, :class_name => 'Membership',
    :inverse_of => :renewed_by_membership,
    :foreign_key => :renewed_by_membership_id, :dependent => :nullify
  has_many :designees, :inverse_of => :membership, :dependent => :delete_all do
    def populate
      return Array.new unless @association.owner.position && @association.owner.position.designable?
      @association.owner.position.committees.except(:order).
      inject([]) do |memo, committee|
        unless committee_ids.include? committee.id
          designee = build
          designee.committee = committee
          memo << designee
        end
        memo
      end
    end
    protected
    def committee_ids
      self.map { |designee| designee.committee_id }.uniq
    end
  end
  has_many :enrollments, through: :position
  has_many :committees, through: :enrollments

  # Memberships that could renewed by assigning the user to this membership:
  # * assigned
  # * not already renewed
  # * of the same position or committee
  # * not overlapping this membership
  # * interested in renewal to some date after membership starts
  # * interested in renewal into the present
  # * user must meet status requirements of the position, if applicable
  scope :renewable_to, lambda { |membership|
    s = assigned.unrenewed.joins("LEFT JOIN enrollments ON " +
      "enrollments.position_id = memberships.position_id").
    where( "memberships.position_id = ? OR " +
      "enrollments.committee_id IN (?)",
       membership.position_id, membership.committee_ids ).
    no_overlap( membership.starts_at, membership.ends_at ).
    where( :renew_until.gte => membership.starts_at ).
    where( :renew_until.gte => Time.zone.today )
    return s unless membership.position.statuses_mask > 0
    s.joins(:user).
    where( "users.statuses_mask & #{membership.position.statuses_mask} > 0" )
  }
  scope :ordered, includes( :user, :period ).order(
    "memberships.ends_at DESC, memberships.starts_at DESC, " +
    "users.last_name ASC, users.first_name ASC, users.middle_name ASC"
  )
  scope :assigned, where { user_id != nil }
  scope :unassigned, where( :user_id => nil )
  scope :requested, where { request_id != nil }
  scope :unrequested, where( :request_id => nil )
  scope :current, lambda { where( :starts_at.lte => Time.zone.today, :ends_at.gte => Time.zone.today ) }
  scope :future, lambda { where( :starts_at.gt => Time.zone.today ) }
  scope :past, lambda { where( :ends_at.lt => Time.zone.today ) }
  scope :current_or_future, lambda { where( :ends_at.gte => Time.zone.today ) }
  # To be renewable a membership must:
  # * have a renewable position
  # * be in either
  # ** a current period
  # ** immediately preceeding a current period
  # * end with the period in which they occur
  scope :renewable, lambda {
    assigned.unrenewed.joins( :position, :period ).merge( Position.unscoped.active.renewable ).
    joins( "LEFT JOIN periods AS next_periods ON " +
      "#{date_add( 'periods.ends_at', 1.day )} = next_periods.starts_at" ).
    where( "memberships.ends_at = periods.ends_at" ).
    where( "(periods.starts_at <= :today AND periods.ends_at >= :today) OR " +
      "(next_periods.starts_at <= :today AND next_periods.ends_at >= :today)",
      :today => Time.zone.today )
  }
  # Unrenewable memberships are associated with unrenewable positions
  scope :unrenewable, lambda { joins(:position).merge( Position.unscoped.unrenewable ) }
  scope :overlap, lambda { |starts, ends| where( :starts_at.lte => ends, :ends_at.gte => starts) }
  scope :no_overlap, lambda { |starts, ends|
    t = arel_table
    where( t[:starts_at].gt( ends ).or( t[:ends_at].lt(starts) ) )
  }
  scope :pending_renewal_within, lambda { |starts, ends|
    renewable.unrenewed.where( :starts_at.gte => starts, :ends_at.lte => ends)
  }
  scope :authorized_user_id_equals, lambda { |user_id|
    select("DISTINCT #{arel_table.name}.*").joins(:position).
    merge( Position.unscoped.joins(:authority).
    merge( Authority.unscoped.joins(:authorized_enrollments).
    merge( Enrollment.unscoped.joins( :memberships ).
    merge( Membership.unscoped.current_or_future.
      overlap( arel_table[:starts_at], arel_table[:ends_at] ).where( :user_id => user_id ) ) ) ) )
  }
  scope :join_notice_pending, lambda { notifiable.current.no_join_notice }
  scope :leave_notice_pending, lambda { notifiable.past.no_leave_notice }
  scope :notifiable, includes(:position).where { user_id != nil }.merge( Position.unscoped.notifiable )
  scope :renewal_confirmed, lambda {
    renewable.where { renewal_confirmed_at != nil }
  }
  scope :renewal_unconfirmed, lambda {
    renewable.where( :renewal_confirmed_at => nil )
  }
  scope :renewed, where { renewed_by_membership_id != nil }
  scope :unrenewed, where( :renewed_by_membership_id => nil )
  scope :user_name_like, lambda { |text| joins(:user).merge( User.unscoped.name_like(text) ) }
  scope :enrollments_committee_id_equals, lambda { |committee_id|
    joins('INNER JOIN enrollments ON enrollments.position_id = memberships.position_id').
    where( [ 'enrollments.committee_id = ?', committee_id ] )
  }

  #TODO: deprecated by switch to ranscack
  #search_methods :user_name_like

  accepts_nested_attributes_for :designees, :reject_if => proc { |a| a['user_name'].blank? }, :allow_destroy => true

  validates :period, presence: true
  validates :position, presence: true
  validates :user_id, uniqueness: { scope: [ :position_id, :period_id ] }
  validates :starts_at, timeliness: { type: :date }
  validates :ends_at, timeliness: { type: :date, on_or_after: :starts_at }
  validates :renew_until, timeliness: { type: :date, after: :ends_at,
    allow_blank: true }
  validate :must_be_within_period, :user_must_be_qualified,
    :concurrent_memberships_must_not_exceed_slots

  before_save :clear_notices, :claim_request
  after_save :populate_unassigned, :close_claimed_request, :claim_renewed_memberships
  after_destroy :populate_unassigned

  def self.concurrent_counts( period, position_id )
    statement_parts = [
        "m.starts_at",
        date_sub('m.starts_at', 1.day),
        date_add('m.ends_at', 1.day),
        "m.ends_at"
      ].map do |marker|
      "SELECT #{marker} AS focus, COUNT(DISTINCT c.id) AS quantity FROM memberships AS m " +
      "LEFT JOIN memberships AS c " +
      "ON c.starts_at <= #{marker} AND c.ends_at >= #{marker} AND c.position_id = #{position_id} " +
      ( ( period.class != Membership || period.persisted? ) ? "AND c.id != #{period.id} " : "" ) +
      ( ( period.class == Membership && !period.user.blank? ) ? "AND c.user_id IS NOT NULL " : "" ) +
      "WHERE m.ends_at >= #{connection.quote period.starts_at} AND " +
      "m.starts_at <= #{connection.quote period.ends_at} AND " +
      "#{marker} >= #{connection.quote period.starts_at} AND " +
      "#{marker} <= #{connection.quote period.ends_at} AND " +
      "m.position_id = #{position_id} " +
      "GROUP BY focus"
    end
    statement = statement_parts.join(" UNION ")
    statement += " ORDER BY focus"
    out = connection.select_rows( statement ).map { |r| [
      ( r.first.class == String ? Time.zone.parse(r.first).to_date : r.first ),
      r.last.to_i
    ] }
    memberships = Membership.unscoped.where(:position_id => position_id)
    if period.class == Membership
      memberships = memberships.where { user_id != nil } unless period.user.blank?
      memberships = memberships.where { id != my { period.id } } if period.persisted?
    end
    if out.empty? || out.first.first != period.starts_at.to_date
      out.unshift( [ period.starts_at.to_date,
        memberships.overlap(period.starts_at,period.starts_at).count ] )
    end
    if out.empty? || out.last.first != period.ends_at.to_date
      out.push( [ period.ends_at.to_date,
        memberships.overlap(period.ends_at,period.ends_at).count ] )
    end
    out
  end

  def concurrent_counts; Membership.concurrent_counts self, position_id; end

  def max_concurrent_count; concurrent_counts.map(&:last).max; end

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

  # Returns the context in which this membership should be framed (useful for polymorphic_path)
  def context
    request || position || raise( "No context is possible" )
  end

  def request_id=(new_id)
    write_attribute :request_id, new_id
    populate_from_request
    new_id
  end

  def request_with_population=(new_request)
    self.request_without_population = new_request
    populate_from_request
    new_request
  end

  alias_method_chain :request=, :population

  # Identify users who are interested in the membership
  def users
    User.joins( :requests ).merge(
    Request.unscoped.active.overlap(starts_at, ends_at).with_positions.merge(
    Position.with_users_status.where( :id => position_id ) ) )
  end

  # Identify requests who are interested in the membership
  def requests
    Request.active.overlap(starts_at, ends_at).with_positions.merge(
    Position.where( :id => position_id ) )
  end

  # Identify users who should be copied on notices related to this membership
  # * not this user
  # * must have membership which:
  # ** is enrolled in a committee this membership's position is enrolled in
  # ** overlaps this membership temporally
  # ** has a membership_notices flag set
  def watchers
    return User.unscoped.where(:id => nil) if new_record? || enrollments.empty?
    User.with_enrollments.
    where { id != my { user_id } }.
    where( 'enrollments.committee_id IN (?)', enrollments.map(&:committee_id) ).
    where( 'enrollments.membership_notices = ?', true ).
    merge( Membership.unscoped.overlap( starts_at, ends_at ) ).
    select('DISTINCT users.*')
  end

  def description
    return request.requestable.to_s if request
    return position.requestables.first.to_s unless position.requestables.empty?
    position.to_s
  end

  def tense
    return nil unless starts_at && ends_at
    return :past if ends_at < Time.zone.today
    return :future if starts_at > Time.zone.today
    :current
  end

  def to_s
    return super unless position && starts_at && ends_at
    "#{position} (#{starts_at.to_s :rfc822} - #{ends_at.to_s :rfc822})"
  end

  protected

  def populate_from_request
    return true if request.blank?
    self.position = request.requestable if request.requestable.class == Position
    self.period ||= position.periods.overlaps(request.starts_at, request.ends_at).last if position
    if !period.blank? && user.blank?
      self.starts_at ||= ( period.starts_at > request.starts_at ? period.starts_at : request.starts_at )
      self.ends_at ||= ( period.ends_at < request.ends_at ? period.ends_at : request.ends_at )
    end
    self.user = request.user
  end

  def user_must_be_qualified
    return unless user && position
    if (position.qualification_ids - user.qualification_ids).size > 0
      errors.add :user, "is not qualified for position"
    end
  end

  def must_be_within_period
    return unless period && starts_at && ends_at
    if starts_at && period && ( period.starts_at > starts_at || period.ends_at < starts_at )
      errors.add :starts_at, "must be within #{period} (#{period.id})"
    end
    if ends_at && period && ( period.starts_at > ends_at || period.ends_at < ends_at )
      errors.add :ends_at, "must be within #{period} (#{period.id})"
    end
  end

  def concurrent_memberships_must_not_exceed_slots
    return unless starts_at && ends_at && position
    unless position.slots > max_concurrent_count
      errors.add :position, "lacks free slots for the specified time period"
    end
  end

  # If the user is blank, clear the notice fields
  def clear_notices
    return true unless user.blank?
    self.join_notice_at = nil
    self.leave_notice_at = nil
    true
  end

  # If this fulfills an active request, assign it to that request
  def claim_request
    return true if request || user.blank?
    self.request = user.requests.joins(:user).active.interested_in( self ).
      readonly(false).first
    true
  end

  # If this renews an existing membership, mark the membership renew
  def claim_renewed_memberships
    return true unless user_id_changed?
    renewed_memberships.clear unless renewed_memberships.empty?
    unless user.blank?
      renewed_memberships << Membership.where(:user_id => user_id).
        renewable_to( self ).select( "DISTINCT memberships.*" )
    end
  end

  # If associated with a new, active request, close the request
  def close_claimed_request
    return true unless request_id_changed? && self.request && request.active?
    request.association(:memberships).reset
    request.close
    true
  end

  def populate_unassigned
    return true if user.blank?
    return true unless destroyed? || period_id_changed? || starts_at_changed? || ends_at_changed?
    # Eliminate unassigned memberships in the new period for this membership
    periods = position.schedule.periods.overlaps( starts_at, ends_at ).to_a
    periods.each do |p|
       position.memberships.unassigned.where( :period_id => p.id ).delete_all
    end
    # Do not populate unassigned memberships if the position is inactive
    return true unless position.active?
    # Fill unassigned memberships for current and previous unfilled period
    unless starts_at_changed? || ends_at_changed?
      periods += position.schedule.periods.overlaps( starts_at_was, ends_at_was ).to_a
    end
    periods.uniq.each do |p|
      position.memberships.populate_unassigned_for_period! p
    end
  end

end

