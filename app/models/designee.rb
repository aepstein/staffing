class Designee < ActiveRecord::Base
  attr_accessible :committee_id, :user_id, :user_name, :_destroy
  attr_readonly :committee_id

  belongs_to :membership, :inverse_of => :designees
  belongs_to :user
  belongs_to :committee, :inverse_of => :designees

  validates_presence_of :membership
  validates_presence_of :user
  validates_presence_of :committee
  validates_uniqueness_of :committee_id, :scope => [ :membership_id ]
  validate :membership_must_have_position_in_committee

  def membership_must_have_position_in_committee
    return unless committee && membership
    unless committee.position_ids.include? membership.position_id
      errors.add :committee, "has no positions corresponding to this membership."
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

