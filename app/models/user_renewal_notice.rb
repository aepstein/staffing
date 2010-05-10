class UserRenewalNotice < ActiveRecord::Base
  default_scope :order => 'user_renewal_notices.starts_at DESC'

  belongs_to :authority

  has_many :sendings, :as => :message, :dependent => :delete_all do
    def populate
      return if proxy_owner.new_record? || proxy_owner.sendings_populated?
      UserRenewalNotice.transaction do
        proxy_owner.lock!
        proxy_owner.users.each { |user| create( :user => user ) }
        proxy_owner.sendings_populated = true
        proxy_owner.save
      end
    end
  end

  validates_date :starts_at
  validates_date :ends_at, :after => :starts_at
  validates_date :deadline, :after => :starts_at

  def after_initialize
    self.starts_at ||= Membership.current.minimum(:starts_at)
    self.ends_at ||= Membership.current.maximum(:ends_at)
    self.deadline ||= Date.today + 2.weeks
  end

  def users
    User.no_notice_since( self.class.to_s, created_at - 1.week ).reject { |user|
      user.memberships.pending_renewal_within(starts_at, ends_at).empty?
    }
  end
end

