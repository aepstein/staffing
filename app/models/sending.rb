class Sending < ActiveRecord::Base
  belongs_to :user
  belongs_to :message, :polymorphic => true

  validates_presence_of :user
  validates_presence_of :message
end

