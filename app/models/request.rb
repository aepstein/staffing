class Request < ActiveRecord::Base
  notifiable_events :reject, :close

  attr_accessible :starts_at, :ends_at, :new_position, :answers_attributes,
    :user_attributes
  attr_accessible :rejected_by_authority_id, :rejection_comment, as: :rejector
  attr_readonly :user_id, :commitee_id

  has_many :answers, inverse_of: :request do
    def populate
      # Generate blank answers for any allowed question not in answer set
      population = proxy_association.owner.questions.reject { |q|
        populated_question_ids.include? q.id
      }.map do |question|
          answer = build
          answer.question = question
          answer
      end
      # Fill in most recent prior answer for each global question populated
      s = proxy_association.owner.user.answers.global.
      where { |t| t.question_id.in( population.map { |a| a.question_id } ) }.
      where(<<-SQL
        answers.updated_at = ( SELECT MAX(a.updated_at) FROM answers AS a
        INNER JOIN requests AS r ON a.request_id = r.id
        WHERE a.question_id = answers.question_id AND r.user_id = #{proxy_association.owner.user_id} )
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
  has_many :enrollments, through: :memberships
  has_many :memberships, inverse_of: :request, dependent: :nullify do
    # Memberships are interested if they
    # * are assigned to the user associated with the request
    # * overlap temporally with the request
    # * are requestable through the committee associated with the request
    #   and are assignable to the user
    def interested
      proxy_association.owner.user.memberships.
      overlap( proxy_association.owner.starts_at, proxy_association.owner.ends_at ).
      where { |m| m.position_id.in(
        proxy_association.owner.requestable_positions.assignable.select { id }
      ) }
    end
    # For each of the user's assigned memberships that is not associated with a
    # request but is associated with a position this request can fulfill
    # assign the membership to this request.
    def claim!
      interested.unrequested.each do |membership|
        self << membership
      end
    end
  end
  has_many :requestable_positions, through: :committee do
    def assignable
      assignable_to(proxy_association.owner.user)
    end
    def assignable_ids
      assignable.map(&:id)
    end
  end

  belongs_to :committee, inverse_of: :requests
  belongs_to :user, inverse_of: :requests
  belongs_to :rejected_by_authority, class_name: 'Authority'
  belongs_to :rejected_by_user, class_name: 'User'

  scope :ordered, includes( :user ).
    order { [ user.last_name, user.first_name, position ] }
  scope :unexpired, lambda { where { ends_at > Time.zone.today } }
  scope :expired, lambda { where { ends_at <= Time.zone.today } }
  scope :overlap, lambda { |starts, ends|
    where { |t| ( t.starts_at <= ends ) & ( t.ends_at >= starts ) }
  }
  scope :rejected, lambda { with_status( :rejected ) }
  scope :unrejected, where( :rejected_at => nil )
  scope :staffed, joins( :memberships )
  scope :unstaffed, joins( "LEFT JOIN memberships ON " +
    "memberships.request_id = requests.id" ).
    where { memberships.id.eq( nil ) }
  scope :active, lambda { unexpired.with_status(:active) }
  scope :inactive, lambda {
    where { ( ends_at <= Time.zone.today ) | ( status != 'active' ) } }
  scope :reject_notice_pending, lambda { rejected.no_reject_notice }

  state_machine :status, :initial => :active do
    state :closed

    state :active do
      validate :must_have_assignable_position, on: :update
    end

    state :rejected do
      validates :rejected_by_authority, presence: true
      validates :rejected_by_user, presence: true
      validates :rejection_comment, presence: true
      validates :rejected_at, timeliness: { type: :datetime }
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

  validates :committee, presence: true
  validates :user, presence: true
  validates :starts_at, timeliness: { type: :date }
  validates :ends_at, timeliness: { type: :date, after: :starts_at }
  validates :user_id, uniqueness: { scope: :committee_id }
  validate :must_have_assignable_position, on: :create

  after_save { |request| request.memberships.claim! }
  after_save :insert_at_new_position

  accepts_nested_attributes_for :answers
  accepts_nested_attributes_for :user

  def questions
    Question.joins { quizzes }.uniq.where { |q| q.quizzes.id.in(
      requestable_positions.assignable.scoped.select { quiz_id } ) }
  end

  def authorities
    Authority.joins { positions }.uniq.readonly(false).where { |a| a.positions.id.in(
      requestable_positions.assignable.select { id } ) }
  end

  def authority_ids; authorities.map(&:id); end

  attr_accessor :new_position

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

  def to_s; committee.to_s; end

  protected

  def must_have_assignable_position
    if requestable_positions.assignable.empty?
      errors.add :committee, "is not among committees user may request"
    end
  end

  def rejected_by_authority_must_be_allowed_to_rejected_by_user
    unless rejected_by_authority.blank? || rejected_by_user.blank? ||
      rejected_by_user.authorities.authorized.include?( rejected_by_authority )
      errors.add :rejected_by_authority,
        "is not among the authorities under which #{rejected_by_user} may reject requests"
    end
  end

  def insert_at_new_position
    return if new_position.blank? || new_position == position
    pos = new_position
    self.new_position = nil
    insert_at pos
  end

end

