class MotionComment < ActiveRecord::Base
  belongs_to :motion, inverse_of: :motion_comments
  belongs_to :user, inverse_of: :motion_comments
  has_many :attachments, as: :attachable, dependent: :destroy
  attr_readonly :motion_id, :user_id

  accepts_nested_attributes_for :attachments, allow_destroy: true

  has_paper_trail

  def to_s(format=nil)
    case format
    when :file
      "#{motion.to_s(:file)}-comment-#{id}"
    else
      super()
    end
  end
end

