class Request < ActiveRecord::Base
  default_scope :include => [ :user ],
    :order => 'position ASC, users.last_name ASC, users.first_name ASC, users.middle_name ASC'
  scope_procedure :unexpired, lambda { ends_at_gt Date.today }
  scope_procedure :expired, lambda { ends_at_lte Date.today }

  include AASM
  aasm_column :state
  aasm_initial_state :started
  aasm_state :started
  aasm_state :submitted
  aasm_state :reviewed
  aasm_state :released

  acts_as_list :scope => :user_id

  has_many :answers do
    def populated_question_ids
      self.map { |answer| answer.question_id }
    end
    def populate
      # Generate blank answers for any allowed question not in answer set
      population = proxy_owner.allowed_questions.reject { |q| populated_question_ids.include? q.id }.map do |question|
        build :question => question
      end
      # Fill in most recent prior answer for each global question populated
      proxy_owner.user.answers.global.question_id_equals_any( population.map { |a| a.question_id }
      ).descend_by_updated_at.all( :group => 'question_id' ).each do |answer|
        population.select { |a| a.question_id == answer.question_id }.first.content = answer.content
      end
      # Return the populated answers
      population
    end
  end
  belongs_to :requestable, :polymorphic => true
  belongs_to :user

  has_many :memberships do
    def assignable
      proxy_owner.requestable.memberships.position_with_status(proxy_owner.user.status).unassigned.current
    end
  end

  validates_presence_of :requestable
  validates_presence_of :user
  validates_date :starts_at
  validates_date :ends_at, :after => :starts_at
  validate :user_status_must_match_position, :requestable_must_be_requestable

  before_validation_on_create :initialize_answers

  def allowed_positions
    return [] unless requestable
    case requestable.class.to_s
    when 'Position'
      [requestable]
    else
      requestable.positions.with_status( user.status )
    end
  end

  def allowed_quizzes
    allowed_positions.map { |position| position.quiz }
  end

  def allowed_questions
    return [] unless allowed_quizzes.length > 0
    Question.quizzes_id_equals_any( allowed_quizzes.map { |q| q.id }.uniq )
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

end

