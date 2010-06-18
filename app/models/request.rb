class Request < ActiveRecord::Base
  default_scope :include => [ :user ],
    :order => 'users.last_name ASC, users.first_name ASC, users.middle_name ASC, position ASC'
  scope_procedure :unexpired, lambda { ends_at_gt Date.today }
  scope_procedure :expired, lambda { ends_at_lte Date.today }
  scope_procedure :overlap, lambda { |starts, ends| starts_at_lte(ends).ends_at_gte(starts) }

  attr_readonly :user_id

  named_scope :authority_id_equals, lambda { |authority_id|
    { :include => [ :user ],
      :joins => "LEFT JOIN enrollments ON " +
        "requests.requestable_type = 'Committee' AND requests.requestable_id = enrollments.committee_id " +
        "LEFT JOIN positions ON " +
        "(requests.requestable_type = 'Position' AND requests.requestable_id = positions.id) OR " +
        "enrollments.position_id = positions.id",
      :conditions => [ "positions.authority_id = ? AND " +
        "( positions.statuses_mask = 0 OR ((positions.statuses_mask & users.statuses_mask) > 0) )", authority_id ],
      :group => 'requests.id' }
  }

  acts_as_list :scope => :user_id

  has_many :answers do
    def populate
      # Generate blank answers for any allowed question not in answer set
      population = proxy_owner.questions.reject { |q| populated_question_ids.include? q.id }.map do |question|
        build :question => question
      end
      # Fill in most recent prior answer for each global question populated
      proxy_owner.user.answers.global.question_id_equals_any( population.map { |a| a.question_id }
      ).descend_by_updated_at.all( :group => 'question_id' ).each do |answer|
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
  belongs_to :user

  has_many :memberships, :dependent => :nullify do
    def assignable
      proxy_owner.requestable.memberships.overlaps( proxy_owner.starts_at, proxy_owner.ends_at
      ).position_with_status( proxy_owner.user.status ).unassigned
    end
  end

  validates_presence_of :requestable
  validates_presence_of :user
  validates_date :starts_at
  validates_date :ends_at, :after => :starts_at
  validates_uniqueness_of :user_id, :scope => [ :requestable_type, :requestable_id ]
  validate :user_status_must_match_position, :requestable_must_be_requestable

  before_validation_on_create :initialize_answers
  after_save :claim_memberships!

  def positions
    return Position.id_blank unless requestable
    case requestable.class.to_s
    when 'Position'
      Position.id_equals( requestable.id )
    else
      requestable.positions.with_status( user.status )
    end
  end

  def position_ids
    positions.map { |position| position.id }
  end

  def quizzes
    positions.map { |position| position.quiz }
  end

  def questions
    return Question.id_blank unless quizzes.length > 0
    Question.quizzes_id_equals_any( quizzes.map { |q| q.id }.uniq )
  end

  def authorities
    return Authority.id_blank unless positions.length > 0
    Authority.position_id_equals_any( position_ids )
  end

  def authority_ids
    authorities.map { |authority| authority.id }
  end

  def requestable_must_be_requestable
    return unless requestable
    errors.add :requestable, "is not requestable." unless requestable.requestable?
  end

  def user_status_must_match_position
    return unless requestable && requestable.class == Position
    unless requestable.statuses.empty? || requestable.statuses.include?(user.status)
      errors.add :user, "must have a status of #{requestable.statuses.join ' or '}."
    end
  end

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

  after_save :insert_at_new_position

  accepts_nested_attributes_for :answers
  accepts_nested_attributes_for :user

  protected

  def insert_at_new_position
    return if new_position.blank? || new_position == position
    pos = new_position
    self.new_position = nil
    insert_at pos
  end

  def initialize_answers; answers.each { |a| a.request = self }; end

  def to_s; requestable.to_s; end

  def claim_memberships!
    return if position_ids.empty?
    user.memberships.unrequested.position_id_equals_any(position_ids).each do |membership|
      memberships << membership
    end
  end

end

