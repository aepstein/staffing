class Request < ActiveRecord::Base
  default_scope :include => [ :user ],
    :order => 'users.last_name ASC, users.first_name ASC, users.middle_name ASC'

  include AASM
  aasm_column :state
  aasm_initial_state :started
  aasm_state :started
  aasm_state :submitted
  aasm_state :reviewed
  aasm_state :released

  acts_as_list :scope => [ :user_id ]

  has_many :answers do
    def populate
      proxy_owner.allowed_questions.each { |q| build :question => q }
    end
  end
  belongs_to :requestable, :polymorphic => true
  belongs_to :user

  has_many :memberships

  validates_presence_of :requestable
  validates_presence_of :user
  validates_date :starts_at
  validates_date :ends_at, :after => :starts_at
  validate :user_status_must_match_position

  before_validation_on_create :initialize_answers

  def allowed_questions
    return unless requestable
    case requestable.class.to_s
    when 'Position'
      requestable.quiz.questions
    else
      Question.quiz_id_equals_any(
        requestable.positions.requestable.with_status(proxy_owner.user.status).map { |p| p.quiz_id }
      ).all
    end
  end

  def user_status_must_match_position
    return unless requestable && requestable.class == Position
    unless requestable.statuses.empty? || requestable.statuses.include?(user.status)
      errors.add :user, "must have a status of #{requestable.statuses.join ' or '}."
    end
  end

  accepts_nested_attributes_for :answers

  protected

  def initialize_answers; answers.each { |a| a.request = self }; end

end

