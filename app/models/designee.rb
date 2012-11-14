class Designee < ActiveRecord::Base
  attr_accessible :committee_id, :user_id, :user_name, :_destroy,
    as: [ :default, :creator, :updator ]
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

  def user_name=(name)
    if name.to_net_ids.empty?
      self.user = User.find_by_net_id name[/\(([^\s]*)\)/,1]
    else
      self.user = User.find_or_create_by_net_id name.to_net_ids.first
    end
    self.user = nil if user && user.id.nil?
  end

  def user_name
    return unless user
    "#{user.name} (#{user.net_id})"
  end
end

