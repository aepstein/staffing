class Committee < ActiveRecord::Base
  default_scope :order => 'committees.name ASC'

  named_scope :requestable, { :conditions => { :requestable => true } }
  named_scope :unrequestable, { :conditions => { :requestable => false } }
  named_scope :group_by_id, { :group => "committees.id" }

  has_many :authorities
  has_many :requests, :as => :requestable
  has_many :enrollments
  has_many :positions, :through => :enrollments

  validates_presence_of :name
  validates_uniqueness_of :name

  def memberships
    Membership.enrollments_committee_id_equals( id )
  end

  def current_emails
    memberships.current.all(:include => {:designees => :user, :user => [] }).inject([]) do |memo,membership|
      memo << membership.user.name( :email ) if membership.user_id
      membership.designees.each do |designee|
        memo << designee.user.name( :email )
      end
      memo
    end
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

