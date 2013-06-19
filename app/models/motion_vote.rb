class MotionVote < ActiveRecord::Base
  TYPES = %w( affirmative negative present )
  
  belongs_to :motion_event, inverse_of: :motion_votes
  belongs_to :user, inverse_of: :motion_votes
  
  validates :motion_event, presence: true
  validates :user_id, presence: true, inclusion: {
    in: lambda { |vote| vote.motion_event.user_ids },
    if: :motion_event
  }
  
  def type=(t)
    return t if self.type_code=MotionVote::TYPES.index(t)
    nil
  end
  
  def type
    MotionVote::TYPES[type_code]
  end
end
