require 'spec_helper'

describe Answer, :type => :model do
  let(:answer) { build(:answer) }

  it "should create a new instance given valid attributes" do
    answer.save!
  end

  it 'should not save without a question' do
    answer.question = nil
    expect(answer.save).to be false
  end

  it 'should not save without a membership_request' do
    answer.membership_request = nil
    expect(answer.save).to be false
  end

  it 'should not save with a question that is not allowed for the requested position if a position is requested' do
    answer.save!
    disallowed_question = create(:question)
    dis_answer = build(:answer, membership_request: answer.membership_request, question: disallowed_question)
    expect(dis_answer.membership_request.questions).not_to include disallowed_question
    expect(dis_answer.save).to be false
  end
end

