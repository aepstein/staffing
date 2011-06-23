class Committee < ActiveRecord::Base
  default_scope order( 'committees.name ASC' )

  scope :requestable, where( :requestable.eq => true )
  scope :unrequestable, where( :requestable.eq => false )
  scope :group_by_id, group( :id )
  scope :positions_with_status, lambda { |status|
    joins( :positions ).where("(positions.statuses_mask & #{status.nil? ? 0 : 2**User::STATUSES.index(status.to_s)}) > 0 OR positions.statuses_mask = 0")
  }

  attr_accessible :name, :description, :join_message, :leave_message, :brand_id,
    :requestable, :public_url, :schedule_id, :reject_message

  belongs_to :schedule, :inverse_of => :committees
  belongs_to :brand, :inverse_of => :committees
  has_many :periods, :through => :schedule do
    def active
      current.first
    end
  end
  has_many :designees, :inverse_of => :committee
  has_many :authorities, :inverse_of => :committee
  has_many :meetings, :inverse_of => :committee, :dependent => :destroy
  has_many :motions, :inverse_of => :committee, :dependent => :destroy
  has_many :requests, :as => :requestable
  has_many :enrollments, :inverse_of => :committee
  has_many :positions, :through => :enrollments

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :schedule

  def memberships
    return Membership.where( :id => nil ) if new_record?
    Membership.joins(
      'INNER JOIN enrollments ON memberships.position_id = enrollments.position_id'
    ).where( [ 'enrollments.committee_id = ?', id ] )
  end

  def current_emails
    memberships.current.includes(:designees, :user).all.inject([]) { |memo, membership|
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

