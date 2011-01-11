require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Request do
  before(:each) do
    @request = Factory(:request)
  end

  xit "should create a new instance given valid attributes" do
    @request.id.should_not be_nil
  end

  xit  'should not save without a start date' do
    @request.starts_at = nil
    @request.save.should be_false
  end

  xit  'should not save without an end date' do
    @request.ends_at = nil
    @request.save.should be_false
  end

  xit  'should not save with an end date that is before the start date' do
    @request.ends_at = @request.starts_at
    @request.save.should be_false
  end

  xit  'should not save without a requestable' do
    @request.requestable = nil
    @request.save.should be_false
  end

  xit  'should not save without a user' do
    @request.user = nil
    @request.save.should be_false
  end

  xit  'should not save a duplicate for certain user and requestable' do
    duplicate = Factory.build(:request)
    duplicate.user = @request.user
    duplicate.requestable = @request.requestable
    duplicate.save.should be_false
  end

  xit  'should not save if for a position and the user does not meet status requirements of the position' do
    @request.requestable.statuses = ['undergrad']
    @request.requestable.save
    @request.user.status.should_not eql 'undergrad'
    @request.save.should be_false
  end

  xit  'should have an questions method that returns only questions in the quiz of requestable if it is a position' do
    allowed = Factory(:question)
    @request.requestable.quiz.questions << allowed
    unallowed = Factory(:question)
    @request.questions.size.should eql 1
    @request.questions.should include allowed
  end

  xit  'should have an questions method that returns only questions in the quiz of allowed positions of requestable if it is a committee' do
    user = Factory(:user, :status => 'undergrad')
    user.status.should eql 'undergrad'

    allowed = Factory(:question, :name => 'allowed')
    unallowed = Factory(:question, :name => 'unallowed')
    other = Factory(:question, :name => 'other')

    allowed_quiz = Factory(:quiz, :questions => [ allowed ])
    unallowed_quiz = Factory(:quiz, :questions => [ unallowed ])
    other_quiz = Factory(:quiz, :questions => [ allowed, unallowed, other ])

    allowed_position = Factory(:position, :statuses => ['undergrad'], :requestable_by_committee => true, :quiz => allowed_quiz)
    unallowed_position_status = Factory(:position, :statuses => ['grad'], :requestable_by_committee => true, :quiz => unallowed_quiz)
    unallowed_position_requestability = Factory(:position, :statuses => ['undergrad'], :quiz => unallowed_quiz)
    other_position = Factory(:position, :statuses => ['undergrad'], :quiz => other_quiz)

    committee = Factory(:committee, :requestable => true)
    Factory(:enrollment, :committee => committee, :position => allowed_position)
    Factory(:enrollment, :committee => committee, :position => unallowed_position_status)
    Factory(:enrollment, :committee => committee, :position => unallowed_position_requestability)
    committee.reload

    request = Factory.build(:request, :requestable => committee, :user => user)
    request.questions.length.should eql 1
    request.questions.should include allowed
    @request.questions.length.should eql 0
  end

  it  'should have answers.populate that populates answers for questions not yet built' do
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
    request.answers.send(:populated_question_ids).size.should eql 1
    request.answers.send(:populated_question_ids).should include unanswered_local.id
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
    qa[unanswered_local].blank?.should be_true
    qa[unanswered_global].blank?.should be_true
    qa[answered_local].blank?.should be_true
    qa[answered_global].should eql 'most recent answer'
  end

  xit  'should have a expired and unexpired scopes' do
    older = Factory(:expired_request)
    old = Factory(:expired_request, :ends_at => Date.today)
    @request.ends_at.should > Date.today
    Request.expired.length.should eql 2
    Request.expired.should include older
    Request.expired.should include old
    Request.unexpired.length.should eql 1
    Request.unexpired.should include @request
  end

  xit  'should claim unrequested memberships that the request could apply to' do
    m = Factory(:membership)
    r = Factory.build(:request, :user => m.user)
    r.stub!(:position_ids).and_return([m.position_id])
    r.save.should be_true
    r.memberships.size.should eql 1
    r.memberships.should include m
  end

  xit  'should have a rejected? method that returns rejected_at? result' do
    @request.rejected_at.should be_nil
    @request.rejected?.should be_false
    @request.rejected_at = Time.zone.now
    @request.rejected?.should be_true
  end

  xit  'should save with valid parameters from administrator' do
    setup_rejection
    @request.reject(@valid_parameters).should be_true
  end

  xit  'should save with valid parameters from authorized user for the authority' do
    setup_rejection
    @request.rejected_by_user = @authorized
    @request.reject(@valid_parameters).should be_true
  end

  xit  'should not save with valid parameters from unauthorized user for the authority' do
    setup_rejection
    @request.rejected_by_user = @unauthorized
    @request.reject(@valid_parameters).should be_false
  end

  xit  'should not save if rejected without a comment' do
    setup_rejection
    @valid_parameters.delete(:rejection_comment)
    @request.reject(@valid_parameters).should be_false
  end

  xit  'should have an unreject method that removes rejection status' do
    setup_rejection
    @request.reject(@valid_parameters).should be_true
    @request.unreject.should be_true
    @request.rejected?.should be_false
  end

  xit  'should have a send_reject_notice! method which sends a rejection notice and saves' do
    setup_rejection
    @request.reject(@valid_parameters).should be_true
    @request.send_reject_notice!
    @request.reload
    @request.rejection_notice_at.should_not be_nil
  end

  xit  'should have a reject_notice_pending scope' do
    Request.reject_notice_pending.length.should eql 0
    setup_rejection
    @request.reject(@valid_parameters).should be_true
    Request.reject_notice_pending.length.should eql 1
    @request.send_reject_notice!
    Request.reject_notice_pending.length.should eql 0
  end

  def setup_rejection
    @admin = Factory(:user, :admin => true)
    @authorized = Factory(:user)
    enrollment = Factory(:enrollment)
    @authority = Authority.find @request.authorities.first.id
    @authority.committee = enrollment.committee
    @authority.save.should be_true
    membership = Factory(:membership, :position => enrollment.position, :user => @authorized )
    @unauthorized = Factory(:user)
    @request.rejected_by_user = @admin
    @valid_parameters = { :rejected_by_authority_id => @authority.id,
      :rejection_comment => 'a comment' }
  end

  def generate_answered_request(user, quiz, answer)
    request = Factory.build(:request, :user => user, :requestable => Factory(:position, :quiz => quiz) )
    quiz.questions.each do |question|
      request.answers.build(:content => answer, :question => question)
    end
    request.save!
    request
  end
end

