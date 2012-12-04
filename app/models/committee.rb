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
    :requestable, :public_url, :meeting_template_id, :schedule_id,
    :reject_message, :active, :contact_name, :contact_email,
    :enrollments_attributes

  belongs_to :schedule, inverse_of: :committees
  belongs_to :brand, inverse_of: :committees
  belongs_to :meeting_template, inverse_of: :committees
  has_many :periods, through: :schedule do
    def active; current.first; end
  end
  has_many :designees, inverse_of: :committee
  has_many :authorities, inverse_of: :committee
  has_many :meetings, inverse_of: :committee, dependent: :destroy
  has_many :motions, inverse_of: :committee, dependent: :destroy
  has_many :membership_requests, inverse_of: :committee
  has_many :enrollments, inverse_of: :committee, dependent: :destroy
  has_many :member_watcher_enrollments, conditions: { membership_notices: true },
    class_name: 'Enrollment'
  has_many :member_watchers, through: :member_watcher_enrollments, source: :users
  has_many :manager_enrollments, conditions: { manager: true },
    class_name: 'Enrollment'
  has_many :managers, through: :manager_enrollments, source: :users
  has_and_belongs_to_many :watchers, class_name: 'User',
    join_table: 'committees_watchers'
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
    def with_roles( *roles )
      where { |m| m.enrollments.id.in( Enrollment.with_roles( roles ).select { id } ) }
    end
  end
  has_many :requestable_enrollments, class_name: 'Enrollment',
    conditions: { requestable: true }
  has_many :requestable_positions, through: :requestable_enrollments,
    source: :position, conditions: { active: true }

  accepts_nested_attributes_for :enrollments, allow_destroy: true

  delegate :effective_contact_name_and_email, to: :committee

  validates :name, presence: true, uniqueness: true
  validates :schedule, presence: true

  def effective_contact_name
    return contact_name if contact_name?
    Staffing::Application.app_config['defaults']['authority']['contact_name']
  end

  def effective_contact_email
    return contact_email if contact_email?
    Staffing::Application.app_config['defaults']['authority']['contact_email']
  end

  def effective_contact_name_and_email
    "\"#{effective_contact_name}\" <#{effective_contact_email}>"
  end

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

