class Sending < ActiveRecord::Base
  belongs_to :user
  belongs_to :message, :polymorphic => true

  validates_presence_of :user
  validates_presence_of :message

  scope :incomplete, where( :completed_at => nil )
  scope :complete, where( :completed_at.ne => nil )

  def deliver!
    SendingMailer.sending( self ).deliver
    self.completed_at = Time.now
    save
  end

end

