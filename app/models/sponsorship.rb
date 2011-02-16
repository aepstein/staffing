class Sponsorship < ActiveRecord::Base
  belongs_to :motion, :inverse_of => :sponsorships
  belongs_to :user, :inverse_of => :sponsorships

  validates_presence_of :motion
  validates_presence_of :user
  validates_uniqueness_of :motion_id, :scope => [ :user_id ]
  validate :user_must_be_allowed

  def user_must_be_allowed
    return unless motion && user
    errors.add( :user, 'is not allowed for motion' ) unless motion.users.allowed.include? user
  end
end

