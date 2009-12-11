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

  has_one :membership

  validates_presence_of :position
  validates_presence_of :user
  validate :must_have_periods

  before_validation_on_create :initialize_answers

  def must_have_periods
    errors.add :periods, "must be selected." if periods.empty?
  end

  accepts_nested_attributes_for :answers

  protected

  def initialize_answers; answers.each { |a| a.request = self }; end

end

