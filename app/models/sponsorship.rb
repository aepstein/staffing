class Sponsorship < ActiveRecord::Base
  include UserNameLookup

  attr_accessible :motion_id, :user_id, :user_name, :_destroy, as: [ :admin, :default ]
  attr_readonly :motion_id, :user_id

  belongs_to :motion, inverse_of: :sponsorships
  belongs_to :user, inverse_of: :sponsorships

  validates :motion, presence: true
  validates :user, presence: true
  validates :motion_id, uniqueness: { scope: :user_id }
  validate :user_must_be_allowed

  def to_s
    if new_record?
      "New Sponsorship"
    else
      user ? user.to_s : super
    end
  end

  protected

  def user_must_be_allowed
    return unless motion && user
    errors.add( :user, 'is not allowed for motion' ) unless motion.users.allowed.include? user
  end
end

