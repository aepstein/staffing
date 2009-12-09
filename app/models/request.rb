class Request < ActiveRecord::Base
  has_and_belongs_to_many :terms
  belongs_to :position
  belongs_to :user

  has_one :membership

  validates_presence_of :position
  validates_presence_of :user
  validate :must_have_terms

  def must_have_terms
    errors.add :terms, "must be selected." if terms.empty?
  end
end

