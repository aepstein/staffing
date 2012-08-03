class Committee < ActiveRecord::Base
  default_scope lambda { ordered }

  scope :ordered, order { name }
  scope :group_by_id, group( :id )
  scope :requestable_for_user, lambda { |user|
    active.where { |c| c.id.in( Enrollment.unscoped.requestable.select(:committee_id).
      joins(:position).merge( Position.unscoped.active.with_status(user.status) )
    ) }
  }
  scope :active, where { active.eq( true ) }
  scope :inactive, where { active.not_eq( true ) }

  attr_accessible :name, :description, :join_message, :leave_message, :brand_id,
    :requestable, :public_url, :schedule_id, :reject_message, :active

  belongs_to :schedule, inverse_of: :committees
  belongs_to :brand, inverse_of: :committees
  has_many :periods, through: :schedule do
    def active
      current.first
    end
  end
  has_many :designees, inverse_of: :committee
  has_many :authorities, inverse_of: :committee
  has_many :meetings, inverse_of: :committee, dependent: :destroy
  has_many :motions, inverse_of: :committee, dependent: :destroy
  has_many :requests, inverse_of: :committee
  has_many :enrollments, inverse_of: :committee, dependent: :destroy
  has_many :watcher_enrollments, conditions: { membership_notices: true },
    class_name: 'Enrollment'
  has_many :watchers, through: :watcher_enrollments, source: :users
  has_many :positions, through: :enrollments
  has_many :memberships, through: :positions do
    def tents(date)
      out = as_of(date).assigned.includes { [ user, enrollments ] }.except(:order).
      merge( User.unscoped.ordered ).order { enrollments.title }.
      inject({}) do |memo, membership|
        memo[membership.user] ||= []
        memo[membership.user] += membership.enrollments.map(&:title)
        memo
      end
      out.map { |user, titles| [ user.name, titles.uniq.join(', '),
        ( user.portrait? ? user.portrait.small.path : nil ) ] }
    end
  end
  has_many :requestable_enrollments, class_name: 'Enrollment',
    conditions: { requestable: true }
  has_many :requestable_positions, through: :requestable_enrollments,
    source: :position, conditions: { active: true }

  validates :name, presence: true, uniqueness: true
  validates :schedule, presence: true

  def current_emails
    memberships.current.includes(:designees, :user).except(:order).all.
    inject([]) { |memo, membership|
      memo << membership.user.name( :email ) if membership.user_id
      membership.designees.each do |designee|
        memo << designee.user.name( :email )
      end
      memo
    }
  end

  def name(style=nil)
    case style
    when :file
      self.name.strip.downcase.gsub(/[^a-z]/,'-').squeeze('-')
    else
      read_attribute(:name)
    end
  end

  def to_s; name; end
end

