require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Request do
  before(:each) do
    @request = Factory(:request)
  end

  it "should create a new instance given valid attributes" do
    @request.id.should_not be_nil
  end

  it 'should not save without a start date' do
    @request.starts_at = nil
    @request.save.should be_false
  end

  it 'should not save without an end date' do
    @request.ends_at = nil
    @request.save.should be_false
  end

  it 'should not save with an end date that is before the start date' do
    @request.ends_at = @request.starts_at
    @request.save.should be_false
  end

  it 'should not save without a requestable' do
    @request.requestable = nil
    @request.save.should be_false
  end

  it 'should not save without a user' do
    @request.user = nil
    @request.save.should be_false
  end

  it 'should not save if for a position and the user does not meet status requirements of the position' do
    @request.requestable.statuses = ['undergrad']
    @request.requestable.save
    @request.user.status.should_not eql 'undergrad'
    @request.save.should be_false
  end

  it 'should have an allowed_questions method that returns only questions in the quiz of requestable if it is a position' do
    allowed = Factory(:question)
    @request.requestable.quiz.questions << allowed
    unallowed = Factory(:question)
    @request.allowed_questions.size.should eql 1
    @request.allowed_questions.should include allowed
  end

  it 'should have an allowed_questions method that returns only questions in the quiz of allowed positions of requestable if it is a committee' do
    allowed = Factory(:question)
    committee = Factory(:committee)
    allowed_position = Factory(:position)
    allowed_position.quiz.questions << allowed
    Factory(:enrollment, :committee => committee, :position => allowed_position)
    disallowed_position = Factory(:position, :statuses => [ 'temporary' ])
    disallowed_position.statuses.should_not include @request.user.status
    disallowed_position.quiz.questions << Factory(:question)
    Factory(:enrollment, :committee => committee, :position => disallowed_position)
    outside_position = Factory(:position)
    outside_position.quiz.questions << Factory(:question)
    @request = Factory(:request, :requestable => committee)
  end

  it 'should have a expired and unexpired scopes' do
    older = Factory(:expired_request)
    old = Factory(:expired_request, :ends_at => Date.today)
    @request.ends_at.should > Date.today
    Request.expired.length.should eql 2
    Request.expired.should include older
    Request.expired.should include old
    Request.unexpired.length.should eql 1
    Request.unexpired.should include @request
  end
end

