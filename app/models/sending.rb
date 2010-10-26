class Sending < ActiveRecord::Base
  belongs_to :user
  belongs_to :message, :polymorphic => true

  validates_presence_of :user
  validates_presence_of :message

  scope :incomplete, lambda { completed_at_null }
  scope :complete, lambda { completed_at_not_null }

  def deliver!
    SendingMailer.deliver_sending self
    self.completed_at = Time.now
    save
  end

end

