class Committee < ActiveRecord::Base
  default_scope :order => 'committees.name ASC'

  named_scope :requestable, { :conditions => { :requestable => true } }
  named_scope :unrequestable, { :conditions => { :requestable => false } }

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
      memo << membership.user.name( :email )
      membership.designees.each do |designee|
        memo << designee.user.name( :email )
      end
      memo
    end
  end

  def to_s; name; end
end

