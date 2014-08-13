class Designee < ActiveRecord::Base
  include UserNameLookup
  
  PERMITTED_ATTRIBUTES = [ :id, :_destroy, :committee_id, :user_id, :user_name ]
  attr_readonly :committee_id

  belongs_to :membership, inverse_of: :designees
  belongs_to :user, inverse_of: :designees
  belongs_to :committee, inverse_of: :designees

  validates :membership, presence: true
  validates :user, presence: true
  validates :committee, presence: true
  validates :committee_id, uniqueness: { scope: [ :membership_id ] }
  validate :membership_must_have_designable_position_in_committee

  def membership_must_have_designable_position_in_committee
    return unless committee && membership
    unless ( membership.position.designable? && committee.positions.
      except(:order).include?( membership.position ) )
      errors.add :committee, "has no designable positions corresponding to this membership"
    end
  end
end

