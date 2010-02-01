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

  has_many :answers do
    def populate
      proxy_owner.position.quiz.questions.each { |q| build( :question => q ) }
    end
  end
  has_and_belongs_to_many :periods
  belongs_to :position
  belongs_to :user

  has_many :memberships

  validates_presence_of :position
  validates_presence_of :user
  validate :must_have_periods, :user_status_must_match_position

  before_validation_on_create :initialize_answers

  def must_have_periods
    errors.add :periods, "must be selected." if periods.empty?
  end

  def user_status_must_match_position
    return unless position
    unless position.statuses.empty? || position.statuses.include?(user.status)
      errors.add :user, "must have a status of #{position.statuses.join ' or '}."
    end
  end

  accepts_nested_attributes_for :answers

  protected

  def initialize_answers; answers.each { |a| a.request = self }; end

end

