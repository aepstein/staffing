class UserRenewalNotice < ActiveRecord::Base
  default_scope :order => 'user_renewal_notices.starts_at DESC'

  belongs_to :authority

  validates_date :starts_at
  validates_date :ends_at, :after => :starts_at
  validates_date :deadline, :after => :starts_at
end

