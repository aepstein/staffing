class Membership < ActiveRecord::Base
  notifiable_events :join, :leave, :decline, :appoint
  attr_readonly :position_id

  include UserNameLookup

  attr_accessor :modifier, :in_decline

  belongs_to :user, inverse_of: :memberships
  belongs_to :period, inverse_of: :memberships
  belongs_to :position, inverse_of: :memberships
  belongs_to :membership_request, inverse_of: :memberships
  belongs_to :renewed_by_membership, class_name: 'Membership',
    inverse_of: :renewed_memberships
  belongs_to :declined_by_user, class_name: 'User',
    inverse_of: :declined_memberships
  has_one :authority, through: :position
  has_many :enrollments, primary_key: :position_id,
    foreign_key: :position_id
  has_many :renewed_memberships, class_name: 'Membership',
    inverse_of: :renewed_by_membership, foreign_key: :renewed_by_membership_id,
    dependent: :nullify do
    def candidates
      Membership.unscoped.includes(:user).renewable_to( proxy_association.owner ).
      merge( User.unscoped.ordered )
    end
  end
  has_many :designees, inverse_of: :membership, dependent: :delete_all do
    def populate
      return Array.new unless ( proxy_association.owner.position &&
      proxy_association.owner.position.designable? )
      proxy_association.owner.position.committees.except(:order).
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
  has_many :enrollments, through: :position do
    def for_committee( committee )
      where { committee_id == my { committee.id } }
    end
    def titles_for_committee( committee )
      for_committee(committee).map(&:title).join(",")
    end
    def votes_for_committee( committee )
      for_committee(committee).map(&:votes).join(",")
    end
  end
  has_many :committees, through: :enrollments
  # Peer memberships overlap this membership and share at least one committee
  # The membership must be persisted in order to use this relation
  has_many :peers, through: :committees, source: :memberships, uniq: true,
    conditions: Proc.new {
    [ "memberships.starts_at <= ? AND memberships.ends_at >= ? AND memberships.id <> ?",
      ends_at, starts_at, id ]
  }
  has_many :membership_requests, through: :position,
    source: :candidate_membership_requests do
    def overlapping
      overlap( proxy_association.owner.starts_at, proxy_association.owner.ends_at )
    end
    def interested; overlapping.active; end
  end
  has_many :users, through: :membership_requests, source: :user do
    def assignable; User.assignable_to( proxy_association.owner.position ); end
  end

  # Memberships that would close a membership request if assigned to its user
  scope :would_close, lambda { |membership_request|
    unassigned.
    overlap( membership_request.starts_at, membership_request.ends_at ).
    where { |r| r.position_id.in( membership_request.requestable_positions.
      scoped.select { id } ) }
  }
  # Memberships that could be renewed by assigning the user to this membership:
  # * assigned
  # * unrenewed
  # * renewable
  # * same position or committee
  # interested in renewal to date after this membership starts,
  # * if position.statuses_mask > 0, having user.statuses_mask & position.
  #   statuses_mask > 0
  scope :renewable_to, lambda { |membership|
    s = renewal_candidate.no_overlap( membership.starts_at, membership.ends_at ).
    renew_until( membership.starts_at ).renew_active.
    equivalent_committees_with( membership.position )
    return s unless membership.position.statuses_mask > 0
    s.where { user_id.in(
      User.unscoped.select { id }.where(
        "users.statuses_mask & #{membership.position.statuses_mask} > 0"
      ) ) }
  }
  # Memberships that would renew this membership if the user was assigned
  scope :would_renew, lambda { |membership|
    unassigned.
    equivalent_committees_with( membership.position ).
    where { |m| m.starts_at.gt( membership.ends_at ) &
      m.starts_at.lte( membership.renew_until ) &
      m.position_id.in(
      Position.unscoped.select { id }.where( [
        "statuses_mask = 0 OR statuses_mask & ? > 0",
        membership.user.statuses_mask
      ] )
    ) }
  }
  scope :ordered, joins { user.outer }.
    order { [ ends_at.desc, starts_at.desc, users.last_name, users.first_name,
    users.middle_name ] }
  scope :assigned, where { user_id.not_eq( nil ) }
  scope :unassigned, where( :user_id => nil )
  scope :requested, where { membership_request_id != nil }
  scope :unrequested, where( :membership_request_id => nil )
  scope :ends_within, lambda { |range|
    where { ends_at.gte( Time.zone.today - range ) &
      ends_at.lte( Time.zone.today + range ) }
  }
  scope :current, lambda { where { ( starts_at <= Time.zone.today ) &
    ( ends_at >= Time.zone.today ) } }
  scope :future, lambda { where { starts_at > Time.zone.today } }
  scope :past, lambda { where { ends_at < Time.zone.today } }
  scope :recent, lambda { where { period_id.in( Period.unscoped.recent.select { id } ) } }
  scope :current_or_future, lambda { where { ends_at >= Time.zone.today } }
  scope :active, lambda { current_or_future }
  scope :renewal_candidate, lambda { renewable.assigned.unrenewed.unabridged.recent }
  scope :renewable, lambda { where { position_id.
    in( Position.unscoped.active.renewable.select { id } ) } }
  scope :unrenewable, lambda { where { position_id.
    not_in( Position.unscoped.active.renewable.select { id } ) } }
  scope :abridged, lambda { joins { period }.
    where { ends_at.lt( periods.ends_at ) } }
  scope :unabridged, lambda { joins { period }.
    where { ends_at.eq( periods.ends_at ) } }
  scope :as_of, lambda { |as_of| overlap( as_of, as_of ) }
  scope :overlap, lambda { |starts, ends|
    where { |t| ( t.starts_at <= ends ) & ( t.ends_at >= starts ) } }
  scope :no_overlap, lambda { |starts, ends|
    where { |t| ( t.starts_at > ends ) | ( t.ends_at < starts ) }
  }
  scope :renew_until, lambda { |date| where { renew_until.gte( date ) } }
  scope :renew_active, lambda { renew_until Time.zone.today }
  scope :equivalent_committees_with, lambda { |position|
    where { position_id.in( Position.unscoped.
      equivalent_committees_with( position ).select { id } ) }
  }
  scope :pending_renewal_within, lambda { |starts, ends|
    renewable.unrenewed.
    where { |t| ( t.starts_at >= starts ) & ( t.ends_at <= ends ) }
  }
  scope :authorized_user_id_equals, lambda { |user_id|
    select("DISTINCT #{arel_table.name}.*").joins(:position).
    merge( Position.unscoped.joins(:authority).
    merge( Authority.unscoped.joins(:authorized_enrollments).
    merge( Enrollment.unscoped.joins( :memberships ).
    merge( Membership.unscoped.current_or_future.
      overlap( arel_table[:starts_at], arel_table[:ends_at] ).
      where( :user_id => user_id ) ) ) ) )
  }
  scope :appoint_notice_pending, lambda { notifiable.future.no_appoint_notice }
  scope :join_notice_pending, lambda { notifiable.current.no_join_notice }
  scope :leave_notice_pending, lambda { notifiable.past.no_leave_notice }
  scope :decline_notice_pending, lambda { renewal_declined.no_decline_notice }
  scope :notifiable, includes(:position).where { user_id != nil }.
    merge( Position.unscoped.notifiable )
  scope :renewal_confirmed, lambda {
    renewal_candidate.where { renewal_confirmed_at != nil }
  }
  scope :renewal_unconfirmed, lambda {
    renewal_candidate.where( renewal_confirmed_at: nil )
  }
  scope :renewed, where { renewed_by_membership_id != nil }
  scope :unrenewed, where( :renewed_by_membership_id => nil )
  scope :user_name_cont, lambda { |text|
    where { |t| t.user_id.in( User.unscoped.select { id }.name_cont( text ) ) }
  }
  scope :enrollments_committee_id_equals, lambda { |committee_id|
    joins('INNER JOIN enrollments ON enrollments.position_id = memberships.position_id').
    where( [ 'enrollments.committee_id = ?', committee_id ] )
  }
  scope :renewal_declined, lambda { where { declined_at.not_eq( nil ) } }
  scope :renewal_undeclined, lambda { where { declined_at.eq( nil ) } }
  # Can only use this one if memberships are tied to enrollments
  scope :with_roles, lambda { |*roles|
    where { |m| m.enrollments.id.in( Enrollment.unscoped.with_roles(roles).select { id } ) }
  }

  search_methods :user_name_cont

  accepts_nested_attributes_for :designees,
    reject_if: proc { |a| a['user_name'].blank? },
    allow_destroy: true

  validates :period, presence: true
  validates :position, presence: true
  validates :user_id, uniqueness: { scope: [ :position_id, :period_id ], allow_blank: true }
  validates :starts_at, timeliness: { type: :date }
  validates :ends_at, timeliness: { type: :date, on_or_after: :starts_at }
  validates :renew_until, timeliness: { type: :date, after: :ends_at,
    allow_blank: true }
  validates :declined_by_user, :decline_comment, presence: true, if: :in_decline
  validate :must_be_within_period, :concurrent_memberships_must_not_exceed_slots
  validate :modifier_must_overlap, if: :modifier
  validate :must_fulfill_decline_requirements, if: :in_decline

  before_save :clear_on_user_change, :claim_membership_request,
    :unclaim_membership_request, :undecline_if_renewed
  after_save :populate_unassigned, :close_claimed_membership_request,
    :claim_renewed_memberships
  after_destroy :populate_unassigned

  def must_fulfill_decline_requirements
    if renewed_by_membership
      errors.add :base, "already renewed"
    end
  end

  def decline_renewal(decliner_attributes, options={})
    self.in_decline = true
    assign_attributes decliner_attributes, as: :decliner
    self.declined_at = Time.zone.now
    self.declined_by_user = options.delete(:user)
    out = save
    self.in_decline = false
    out
  end

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
      # When dealing with a persisted membership, don't count the membership against itself
      ( ( period.class == Membership && period.persisted? ) ? "AND c.id != #{period.id} " : "" ) +
      # When dealing with an assigned membership, unassigned memberships are expendable and can be ignored
      ( ( period.class == Membership && period.user ) ? "AND c.user_id IS NOT NULL " : "" ) +
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
    memberships = Membership.unscoped.where( position_id: position_id )
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
  
  def renewal_candidate?; Membership.renewal_candidate.include? self; end
  
  def renewed?; renewed_by_membership_id?; end
  
  def unrenewed?; !renewed?; end

  def confirmed?
    return false unless confirmed_at?
    return membership_request.updated_at < confirmed_at if membership_request
    true
  end

  def unconfirmed?; !confirmed?; end

  def confirm
    self.confirmed_at = Time.zone.now
    save
  end

  # Returns the context in which this membership should be framed (useful for polymorphic_path)
  def context
    membership_request || position || raise( "No context is possible" )
  end

  def description
    return membership_request.committee.to_s if membership_request
    return position.requestable_committees.first.to_s if position.requestable_committees.any?
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

  def modifier_must_overlap
    return unless position && starts_at && ends_at && modifier
    return if permitted_to? :staff
    unless position.authority.authorized_memberships.overlap(starts_at, ends_at).
      where { |m| m.enrollments.votes.gt(0) & m.user_id.eq( modifier.id ) }.any?
      errors.add :modifier,
        "must have authority to modify the position between " +
        "#{starts_at.to_s :us_ordinal} and #{ends_at.to_s :us_ordinal}"
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
    return unless starts_at_changed? || ends_at_changed?
    unless position.slots > max_concurrent_count
      errors.add :position, "lacks free slots for the specified time period"
    end
  end

  # If the user is blank, clear the notice fields
  def clear_on_user_change
    if persisted? && user_id_changed?
      notices.clear
      [ :declined_at, :declined_by_user, :decline_comment, :renew_until,
        :renewal_confirmed_at, :renewed_by_membership ].each do |field|
        self.send "#{field}=", nil
      end
    end
    true
  end
  
  def unclaim_membership_request
    return true unless membership_request
    if membership_request.user != user
      if membership_request.closed? && ( membership_request.memberships - [ self ] ).empty?
        membership_request.reactivate
        # TODO membership_request should see if there are any other memberships that can claim it
      end
      self.membership_request = nil
    end
    true
  end

  # If this fulfills an active membership_request, assign it to that membership_request
  def claim_membership_request
    return true if membership_request || user.blank?
    candidate = membership_requests.interested.first
    candidate.memberships << self if candidate
    true
  end

  # If this membership is renewed, unset the renewal declined state as it is irrelevant
  def undecline_if_renewed
    self.declined_at = nil if renewed_by_membership
  end

  # If this renews an existing membership, mark the membership renewed
  def claim_renewed_memberships
    return true unless user_id_changed?
    renewed_memberships.clear unless renewed_memberships.empty?
    unless user.blank?
      renewed_memberships << Membership.where( user_id: user_id ).
        renewable_to( self ).readonly(false)
    end
  end

  # If associated with a new, active membership_request, close the membership_request
  def close_claimed_membership_request
    return true unless membership_request_id_changed? && membership_request && membership_request.active?
    membership_request.close
    true
  end

  def populate_unassigned
    return true if user.blank?
    return true unless destroyed? || period_id_changed? || starts_at_changed? || ends_at_changed?
    # Eliminate unassigned memberships in the new period for this membership
    periods = position.schedule.periods.overlaps( starts_at, ends_at ).to_a
    periods.each do |p|
       position.memberships.unassigned.where( period_id: p.id ).delete_all
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

