class Sponsorship < ActiveRecord::Base
  include UserNameLookup

  belongs_to :motion, :inverse_of => :sponsorships
  belongs_to :user, :inverse_of => :sponsorships

  validates_presence_of :motion
  validates_presence_of :user
  validates_uniqueness_of :motion_id, :scope => [ :user_id ]
  validate :user_must_be_allowed

  attr_readonly :motion_id, :user_id, :user_name

  def to_s; user ? user.to_s : ''; end

  protected

  def user_must_be_allowed
    return unless motion && user
    errors.add( :user, 'is not allowed for motion' ) unless motion.users.allowed.include? user
  end
end

