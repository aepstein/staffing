class Enrollment < ActiveRecord::Base
  ROLES = %w( chair vicechair monitor )
  attr_accessible :committee_id, :committee_name, :position_name, :position_id,
    :title, :votes, :requestable, :membership_notices, :manager
  attr_readonly :committee_id, :position_id

  belongs_to :position, inverse_of: :enrollments
  belongs_to :committee, inverse_of: :enrollments
  has_many :memberships, through: :position
  has_many :users, through: :memberships

  sifter :role_mask_contains do |role|
    roles_mask.op('&',2**Enrollment::ROLES.index(role)).gt(0)
  end

  scope :ordered, includes( :committee, :position ).
    order { [ committees.name, title, positions.name ] }
  scope :with_roles, lambda { |*roles| where {
      [ my { roles } ].flatten.
      map { |role| sift :role_mask_contains, role }.reduce(&:|)
    }
  }
  scope :membership_notices, lambda {
    ActiveSupport::Deprecation.warn(
      "membership_notices() is deprecated and will be removed from future releases, use with_roles('monitor') instead.",
      caller )
    with_roles('monitor')
  }
  scope :requestable, where { requestable.eq(true) }
  scope :unrequestable, where { requestable.not_eq(true) }

  validates :position, presence: true
  validates :committee, presence: true
  validates :title, presence: true
  validates :votes,
    numericality: { greater_than_or_equal_to: 0, only_integer: true }

  include CommitteeNameLookup, PositionNameLookup

  def roles=(roles)
    roles.reduce(0) { |mask,role| mask += ( ROLES.index(role) ? 2**ROLES.index(role) : 0 ) }
  end

  def roles
    ROLES.select { |role| roles_mask & 2**ROLES.index(role) > 0 }
  end
end

