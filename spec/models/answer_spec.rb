require 'spec_helper'

describe Answer do
  before(:each) do
    @answer = create(:answer)
  end

  it "should create a new instance given valid attributes" do
    @answer.id.should_not be_nil
  end

  it 'should not save without a question' do
    @answer.question = nil
    @answer.save.should be_false
  end

  it 'should not save without a membership_request' do
    @answer.membership_request = nil
    @answer.save.should be_false
  end

  it 'should not save with a question that is not allowed for the requested position if a position is requested' do
    disallowed_question = create(:question)
    answer = build(:answer, membership_request: @answer.membership_request, question: disallowed_question)
    answer.membership_request.questions.should_not include disallowed_question
    answer.save.should be_false
  end
end

