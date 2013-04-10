class MotionComment < ActiveRecord::Base
  belongs_to :motion, inverse_of: :motion_comments
  belongs_to :user, inverse_of: :motion_comments
  has_many :attachments, as: :attachable, dependent: :destroy
  attr_accessible :comment, :attachments_attributes, as: [ :staff, :default ]
  attr_readonly :motion_id, :user_id

  accepts_nested_attributes_for :attachments, allow_destroy: true

  has_paper_trail
end

