class UserRenewalNotice < ActiveRecord::Base
  belongs_to :authority

  has_many :sendings, :as => :message, :dependent => :delete_all do
    def populate!
      return if proxy_owner.new_record? || proxy_owner.sendings_populated?
      UserRenewalNotice.transaction do
        proxy_owner.lock!
        proxy_owner.users.each { |user| create( :user => user ) }
        proxy_owner.sendings_populated = true
        proxy_owner.save
      end
    end
  end

  default_scope order( 'user_renewal_notices.starts_at DESC' )

  scope :unpopulated, where( [ 'user_renewal_notices.sendings_populated IS NULL OR ' +
    'user_renewal_notices.sendings_populated = ?', false ] )
  scope :populated, where( :sendings_populated => true )

  validates_date :starts_at
  validates_date :ends_at, :after => :starts_at
  validates_date :deadline, :after => :starts_at

  after_initialize do |notice|
    notice.starts_at ||= Membership.current.minimum(:starts_at)
    notice.ends_at ||= Membership.current.maximum(:ends_at)
    notice.deadline ||= Date.today + 2.weeks
  end

  def subject; 'Your Action is Required to Renew Your Committee Memberships'; end

  def users
    User.no_notice_since( self.class.to_s, created_at - 1.week ).reject { |user|
      user.memberships.pending_renewal_within(starts_at, ends_at).unconfirmed.empty?
    }
  end
end

