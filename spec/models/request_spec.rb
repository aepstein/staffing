require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Request do
  before(:each) do
    @request = create(:request)
  end

  it "should create a new instance given valid attributes" do
    @request.id.should_not be_nil
  end

  it  'should not save without a start date' do
    @request.starts_at = nil
    @request.save.should be_false
  end

  it  'should not save without an end date' do
    @request.ends_at = nil
    @request.save.should be_false
  end

  it  'should not save with an end date that is before the start date' do
    @request.ends_at = @request.starts_at
    @request.save.should be_false
  end

  it  'should not save without a committee' do
    @request.committee = nil
    @request.save.should be_false
  end

  it  'should not save without a user' do
    @request.user = nil
    @request.save.should be_false
  end

  it  'should not save a duplicate for certain user and committee' do
    duplicate = build(:request)
    duplicate.user = @request.user
    duplicate.committee = @request.committee
    duplicate.save.should be_false
  end

  it  'should not save if for a committee and the user does not meet status requirements of the requestable positions for that committee' do
    position = @request.requestable_positions.first
    position.statuses = ['undergrad']
    position.save!
    @request.requestable_positions.proxy_association.reset
    @request.user.statuses.should_not include 'undergrad'
    @request.save.should be_false
  end

  it  'should have an questions method that returns only questions in the quiz of requestable if it is a position' do
    allowed = create(:question)
    @request.requestable_positions.first.quiz.questions << allowed
    unallowed = create(:question)
    @request.questions.size.should eql 1
    @request.questions.should include allowed
  end

  it  'should have an questions method that returns only questions in the quiz of allowed positions of requestable if it is a committee' do
    user = create(:user, :status => 'undergrad')
    user.status.should eql 'undergrad'

    allowed = create(:question, :name => 'allowed')
    unallowed = create(:question, :name => 'unallowed')
    other = create(:question, :name => 'other')

    allowed_quiz = create(:quiz, :questions => [ allowed ])
    unallowed_quiz = create(:quiz, :questions => [ unallowed ])
    other_quiz = create(:quiz, :questions => [ allowed, unallowed, other ])

    allowed_position = create(:position, :statuses => ['undergrad'], :requestable_by_committee => true, :quiz => allowed_quiz)
    unallowed_position_status = create(:position, :statuses => ['grad'], :requestable_by_committee => true, :quiz => unallowed_quiz)
    unallowed_position_requestability = create(:position, :statuses => ['undergrad'], :quiz => unallowed_quiz)
    other_position = create(:position, :statuses => ['undergrad'], :quiz => other_quiz)

    committee = create(:committee, :requestable => true)
    create(:enrollment, :committee => committee, :position => allowed_position)
    create(:enrollment, :committee => committee, :position => unallowed_position_status)
    create(:enrollment, :committee => committee, :position => unallowed_position_requestability)
    committee.reload

    request = build(:request, :requestable => committee, :user => user)
    request.questions.length.should eql 1
    request.questions.should include allowed
    @request.questions.length.should eql 0
  end

  it  'should have answers.populate that populates answers for questions not yet built' do
    user = create(:user)

    unanswered_local = create(:question, :name => 'unanswered local')
    unanswered_global = create(:question, :name => 'unanswered global', :global => true)
    answered_local = create(:question, :name => 'answered local')
    answered_global = create(:question, :name => 'answered global', :global => true)
    excluded = create(:question, :name => 'excluded')
    questions = [ unanswered_local, unanswered_global, answered_local, answered_global ]
    answered_questions = [ answered_local, answered_global ]

    short_quiz = create(:quiz, :questions => answered_questions)
    full_quiz = create(:quiz, :questions => questions)

    less_recent = generate_answered_request user, short_quiz, 'less recent answer'
    sleep 1
    most_recent = generate_answered_request user, short_quiz, 'most recent answer'

    request = build(:request, :user => user, :requestable => create(:position, :quiz => full_quiz))
    a = request.answers.build
    a.question = unanswered_local
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

  it  'should have a expired and unexpired scopes' do
    older = create(:expired_request)
    old = create(:expired_request, :ends_at => Date.today)
    @request.ends_at.should > Date.today
    Request.expired.length.should eql 2
    Request.expired.should include older
    Request.expired.should include old
    Request.unexpired.length.should eql 1
    Request.unexpired.should include @request
  end

  it  'should claim unrequested memberships that the request could apply to' do
    m = create(:membership)
    r = build(:request, user: m.user)
    create(:enrollment, requestable: true, position: m.position, committee: r.committee)
#    r.stub!(:position_ids).and_return([m.position_id])
    r.save.should be_true
    r.memberships.size.should eql 1
    r.memberships.should include m
  end

  context 'rejection' do
    before(:each) do
      Request.reject_notice_pending.length.should eql 0
      @admin = create(:user, admin: true)
      @authorized = create(:user)
      enrollment = create(:enrollment)
      @authority = @request.authorities.first
      @authority.committee = enrollment.committee
      @authority.save.should be_true
      membership = create(:membership, :position => enrollment.position, :user => @authorized )
      @unauthorized = create(:user)
      @request.rejected_by_user = @admin
      @request.rejected_by_authority = @authority
      @request.rejection_comment = 'a comment'
    end

    it  'should save with valid parameters from administrator' do
      @request.reject!
    end

    it  'should save with valid parameters from authorized user for the authority' do
      @request.rejected_by_user = @authorized
      @request.reject!
    end

    it  'should not save with valid parameters from unauthorized user for the authority' do
      @request.rejected_by_user = @unauthorized
      @request.reject.should be_false
    end

    it  'should not save if rejected without a comment' do
      @request.rejection_comment = nil
      @request.reject.should be_false
    end

    it  'should have an unreject method that removes rejection status' do
      @request.reject!
      @request.reactivate.should be_true
      @request.rejected?.should be_false
    end

    it  'should have a send_reject_notice! method which sends a rejection notice and saves' do
      @request.reject!
      @request.send_reject_notice!
      @request.reload
      @request.reject_notice_at.should_not be_nil
    end

    it 'should have a reject_notice_pending scope' do
      @request.reject!
      Request.reject_notice_pending.length.should eql 1
      @request.send_reject_notice!
      Request.reject_notice_pending.length.should eql 0
    end
  end

  it 'should have an interested_in that identifies requests staffable to and temporily interested in a membership' do
    interested_in_scenario :position_statuses_mask => 1, :committee => true,
      :user_statuses_mask => 0, :request_expired => false,
      :requestable_by_committee => true, :success => false
    interested_in_scenario :position_statuses_mask => 0, :committee => true,
      :user_statuses_mask => 0, :request_expired => false,
      :requestable_by_committee => true, :success => true
    interested_in_scenario :position_statuses_mask => 0, :committee => true,
      :user_statuses_mask => 0, :request_expired => false,
      :requestable_by_committee => false, :success => false
  end

  # Accepts attributes to allow testing for a variety of scenarios:
  # * requestable_by_committee: Is the position requestable by committee?
  # * position_statuses_mask: The mask of the position associated with the membership
  # * committee: Whether request should be for committee instead of the position
  # * user_statuses_mask: The mask of the user making the request
  # * request_expired: Whether the request coincides with the membership temporily
  # * success: Whether scope should return the request or not
  def interested_in_scenario( params )
    position = create(:position)
    committee = create(:enrollment, position: position, requestable: true ).committee
    request = create(:request,
      user: create(:user, statuses_mask: params[:user_statuses_mask]),
      committee: committee )
    position.reload
    create(:period, schedule: position.schedule)
    membership = position.memberships.first
    membership.position_id.should eql position.id
    if params[:request_expired]
      request.ends_at = membership.starts_at - 1.day
      request.starts_at = request.ends_at - 1.year
    else
      request.ends_at = membership.starts_at + 1.year
      request.starts_at = request.ends_at - 2.years
    end
    request.save!
    committee.enrollments.first.update_attribute :requestable, params[:requestable_by_committee]
    position.update_attribute :statuses_mask, params[:position_statuses_mask]
    scope = Request.joins(:user).interested_in( membership ).uniq
    if params[:success]
      scope.length.should eql 1
      scope.should include request
    else
      scope.length.should eql 0
    end
  end

  def generate_answered_request(user, quiz, answer)
    request = build(:request, user: user, committee: create(:enrollment,
      position: create(:position, quiz: quiz)).committee )
    quiz.questions.each do |question|
      a = request.answers.build
      a.content = answer
      a.question = question
    end
    request.save!
    request
  end
end

