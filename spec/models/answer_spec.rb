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

  it 'should not save without a request' do
    @answer.request = nil
    @answer.save.should be_false
  end

  it 'should not save with a question that is not allowed for the requested position if a position is requested' do
    disallowed_question = create(:question)
    answer = build(:answer, request: @answer.request, question: disallowed_question)
    answer.request.questions.should_not include disallowed_question
    answer.save.should be_false
  end
end

