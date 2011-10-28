class Request < ActiveRecord::Base
  include Notifiable
  notifiable_events :reject, :close


  UPDATABLE_ATTRIBUTES = [ :starts_at, :ends_at, :new_position,
    :answers_attributes, :user_attributes ]
  REJECTABLE_ATTRIBUTES = [ :rejected_by_authority_id, :rejection_comment ]
  # Criteria to identify positions staffable to this request
  POSITIONS_JOIN_SQL = "((requests.requestable_type = 'Position' AND " +
    "requests.requestable_id = positions.id) OR " +
    "(enrollments.position_id = positions.id AND " +
    "positions.requestable_by_committee = #{connection.quote true})) AND " +
    "( positions.statuses_mask = 0 OR " +
    "( ( positions.statuses_mask & users.statuses_mask ) > 0 ) )"

  attr_accessible UPDATABLE_ATTRIBUTES
  attr_accessible REJECTABLE_ATTRIBUTES, as: :rejector
  attr_readonly :user_id, :requestable_id, :requestable_type

  has_many :answers, :inverse_of => :request do
    def populate
      # Generate blank answers for any allowed question not in answer set
      population = @association.owner.questions.reject { |q|
        populated_question_ids.include? q.id
      }.map do |question|
          answer = build
          answer.question = question
          answer
      end
      # Fill in most recent prior answer for each global question populated
      s = @association.owner.user.answers.global.where( :question_id.in => population.map { |a| a.question_id }
      ).where(<<-SQL
        answers.updated_at = ( SELECT MAX(a.updated_at) FROM answers AS a
        INNER JOIN requests AS r ON a.request_id = r.id
        WHERE a.question_id = answers.question_id AND r.user_id = #{@association.owner.user_id} )
      SQL
      )
      s.each do |answer|
        fillable_answer = population.select { |a| a.question_id == answer.question_id }.first
        fillable_answer.content = answer.content unless fillable_answer.nil?
      end
      # Return the populated answers
      population
    end
    protected
    def populated_question_ids
      self.map { |answer| answer.question_id }
    end
  end
  belongs_to :requestable, :polymorphic => true
  belongs_to :user, :inverse_of => :requests
  belongs_to :rejected_by_authority, :class_name => 'Authority'
  belongs_to :rejected_by_user, :class_name => 'User'

  has_many :memberships, :inverse_of => :request, :dependent => :nullify do
    def assignable
      @association.owner.requestable.memberships.overlap( @association.owner.starts_at, @association.owner.ends_at
      ).position_with_status( @association.owner.user.status ).unassigned
    end
    def claim!
      return if @association.owner.position_ids.empty?
      @association.owner.user.memberships.unrequested.where(
        :position_id.in => @association.owner.position_ids ).each do |membership|
        self << membership
      end
    end
  end

  scope :ordered, includes( :user ).
    order('users.last_name ASC, users.first_name ASC, users.middle_name ASC, position ASC')
  scope :unexpired, lambda { where( :ends_at.gt => Time.zone.today ) }
  scope :expired, lambda { where( :ends_at.lte => Time.zone.today ) }
  scope :overlap, lambda { |starts, ends|
    where( :starts_at.lte => ends, :ends_at.gte => starts )
  }
  scope :rejected, lambda { with_status( :rejected ) }
  scope :unrejected, where( :rejected_at => nil )
  scope :staffed, joins( :memberships )
  scope :unstaffed, joins( "LEFT JOIN memberships ON memberships.request_id = requests.id" ).
    where( "memberships.id IS NULL" )
  scope :active, lambda { unexpired.with_status(:active) }
  scope :inactive, lambda { where( "requests.ends_at <= ? OR " +
    " requests.status != ?", Time.zone.today, 'active' ) }
  scope :reject_notice_pending, lambda { rejected.no_reject_notice }
  # Joins to enrollments to get position_ids for requests where the requestable
  # is a committee
  scope :with_enrollments, lambda {
    joins( "LEFT JOIN enrollments ON " +
      "requests.requestable_type = 'Committee' AND " +
      "requests.requestable_id = enrollments.committee_id" )
  }
  # Joins to requestable tables
  # * assumes a join with users
  scope :with_positions, lambda {
    joins( "INNER JOIN positions" ).with_enrollments.
    where( Request::POSITIONS_JOIN_SQL )
  }
  # Find requests that may be interested in a membership
  # * must have
  scope :interested_in, lambda { |membership|
    with_positions.where( 'positions.id = ? AND requests.ends_at >= ?',
      membership.position_id, membership.starts_at )
  }
  # Identifies requests an authority may staff
  # * TODO: Should this be deprecated?
  scope :authority_id_equals, lambda { |authority_id|
    with_positions.where( "positions.authority_id = ?", authority_id ).
    group( 'requests.id' )
  }

  state_machine :status, :initial => :active do
    state :active do
      validate :requestable_must_be_requestable, :user_status_must_match_position
    end

    state :closed

    state :rejected do
      validates :rejected_by_authority, :presence => true
      validates :rejected_by_user, :presence => true
      validates :rejection_comment, :presence => true
      validates_datetime :rejected_at
      validate :rejected_by_authority_must_be_allowed_to_rejected_by_user
    end

    before_transition all - :rejected => :rejected do |request, transition|
      request.rejected_at = Time.zone.now
    end

    before_transition all - :closed => :closed do |request, transition|
      request.closed_at = Time.zone.now
    end

    event :reject do
      transition :active => :rejected
    end

    event :close do
      transition :active => :closed
    end

    event :reactivate do
      transition [ :rejected, :closed ] => :active
    end

  end

  acts_as_list :scope => :user_id

  validates :requestable, presence: true
  validates :user, presence: true
  validates :starts_at, timeliness: { type: :date }
  validates :ends_at, timeliness: { type: :date, after: :starts_at }
  validates :user_id, uniqueness: {
    scope: [ :requestable_type, :requestable_id ] }

  after_save { |request| request.memberships.claim! }
  after_save :insert_at_new_position

  accepts_nested_attributes_for :answers
  accepts_nested_attributes_for :user

  def positions
    return Position.where(:id => nil) unless requestable
    case requestable.class.to_s
    when 'Position'
      Position.where( :id => requestable.id )
    else
      requestable.positions.except(:order).with_status( user.status ).
      where( :requestable_by_committee => true )
    end
  end

  def position_ids
    positions.map { |position| position.id }
  end

  def quizzes
    positions.map { |position| position.quiz }
  end

  def questions
    return Question.where(:id => nil) unless quizzes.length > 0
#    ( Question.joins(:quizzes) & Quiz.where( :id.in => quizzes.map(&:id) ) ).uniq
    ( Question.joins(:quizzes).where( "quizzes.id IN (?)", quizzes.map(&:id) ) ).uniq
  end

  def authorities
    return Authority.where(:id => nil) unless positions.length > 0
#    ( Authority.joins(:positions) & Position.where( :id.in => position_ids ) ).uniq
    ( Authority.joins(:positions).where( "positions.id IN (?)", position_ids ) ).uniq
  end

  def authority_ids; authorities.map(&:id); end

  attr_accessor :new_position

  def enrollments
    Enrollment.joins(:memberships).
      merge(Membership.unscoped.where(:request_id => id) )
  end

  def new_position_options
    user.requests.inject( new_record? ? { 'Last Position' => '' } : {} ) do |memo, request|
      if request == self
        memo[request.to_s] = ''
      else
        memo[request.to_s] = request.position
      end
      memo
    end
  end

  def to_s; requestable.to_s; end

  protected

  def rejected_by_authority_must_be_allowed_to_rejected_by_user
    unless rejected_by_authority.blank? || rejected_by_user.blank? ||
      rejected_by_user.authorities.authorized.include?( rejected_by_authority )
      errors.add :rejected_by_authority,
        "is not among the authorities under which #{rejected_by_user} may reject requests"
    end
  end

  def requestable_must_be_requestable
    return unless requestable
    errors.add :requestable, "is not requestable." unless requestable.requestable?
  end

  def user_status_must_match_position
    return unless requestable && requestable.class == Position
    unless requestable.statuses.empty? || (requestable.statuses & user.statuses).any?
      errors.add :user, "must have a status of #{requestable.statuses.join ' or '}."
    end
  end

  def insert_at_new_position
    return if new_position.blank? || new_position == position
    pos = new_position
    self.new_position = nil
    insert_at pos
  end

end

