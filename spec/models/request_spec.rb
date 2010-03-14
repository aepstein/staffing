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

  it 'should have answers.populate that populates answers for allowed_questions not yet built' do
    user = Factory(:user)

    unanswered_local = Factory(:question, :name => 'unanswered local')
    unanswered_global = Factory(:question, :name => 'unanswered global', :global => true)
    answered_local = Factory(:question, :name => 'answered local')
    answered_global = Factory(:question, :name => 'answered global', :global => true)
    excluded = Factory(:question, :name => 'excluded')
    questions = [ unanswered_local, unanswered_global, answered_local, answered_global ]
    answered_questions = [ answered_local, answered_global ]

    short_quiz = Factory(:quiz, :questions => answered_questions)
    full_quiz = Factory(:quiz, :questions => questions)

    less_recent = generate_answered_request user, short_quiz, 'less recent answer'
    sleep 2
    most_recent = generate_answered_request user, short_quiz, 'most recent answer'

    request = Factory.build(:request, :user => user, :requestable => Factory(:position, :quiz => full_quiz))
    request.answers.build(:question => unanswered_local)
    request.answers.populated_question_ids.size.should eql 1
    request.answers.populated_question_ids.should include unanswered_local.id
    answers = request.answers.populate
    answers.length.should eql 3
    question_ids = answers.map { |answer| answer.question_id }
    question_ids.should include unanswered_global.id
    question_ids.should include answered_local.id
    question_ids.should include answered_global.id
    qa = request.answers.inject({}) do |memo, answer|
      memo[answer.question] = answer.content
      memo
    end
    qa[unanswered_local].should be_nil
    qa[unanswered_global].should be_nil
    qa[answered_local].should be_nil
    qa[answered_global].should eql 'most recent answer'
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

  def generate_answered_request(user, quiz, answer)
    request = Factory.build(:request, :user => user, :requestable => Factory(:position, :quiz => quiz) )
    quiz.questions.each do |question|
      request.answers.build(:content => answer, :question => question)
    end
    request.save.should be_true
    request
  end
end

