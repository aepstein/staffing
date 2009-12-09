class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :request

  validates_presence_of :request
  validates_presence_of :question
  validates_presence_of :content
end

