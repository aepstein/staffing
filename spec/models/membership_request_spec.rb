require 'spec_helper'

describe MembershipRequest do
  before(:each) do
    @membership_request = create(:membership_request)
  end

  it "should create a new instance given valid attributes" do
    @membership_request.id.should_not be_nil
  end

  it  'should not save without a start date' do
    @membership_request.starts_at = nil
    @membership_request.save.should be_false
  end

  it  'should not save without an end date' do
    @membership_request.ends_at = nil
    @membership_request.save.should be_false
  end

  it  'should not save with an end date that is before the start date' do
    @membership_request.ends_at = @membership_request.starts_at
    @membership_request.save.should be_false
  end

  it  'should not save without a committee' do
    @membership_request.committee = nil
    @membership_request.save.should be_false
  end

  it  'should not save without a user' do
    @membership_request.user = nil
    @membership_request.save.should be_false
  end

  it  'should not save a duplicate for certain user and committee' do
    duplicate = build(:membership_request)
    duplicate.user = @membership_request.user
    duplicate.committee = @membership_request.committee
    duplicate.save.should be_false
  end

  it 'should not create if for a committee and the user does not meet status requirements of the requestable positions for that committee' do
    committee = create(:requestable_committee)
    position = committee.positions.first
    position.statuses = %w( undergrad )
    position.save!
    membership_request = build(:membership_request, committee: committee)
    membership_request.user.statuses.should_not include 'undergrad'
    membership_request.save.should be_false
  end

  it  'should have an questions method that returns only questions in the quiz of requestable if it is a position' do
    allowed = create(:question)
    create(:quiz_question, quiz: @membership_request.requestable_positions.first.quiz,
      question: allowed, position: 1 )
    @membership_request.requestable_positions.first.quiz.association(:questions).reset
    unallowed = create(:question)
    @membership_request.questions.size.should eql 1
    @membership_request.questions.should include allowed
  end

  it  'should have an questions method that returns only questions in the quiz of allowed positions of associated committee' do
    user = create(:user, :status => 'undergrad')
    user.status.should eql 'undergrad'

    allowed = create(:question, :name => 'allowed')
    unallowed = create(:question, :name => 'unallowed')
    other = create(:question, :name => 'other')

    allowed_quiz = create(:quiz)
    create(:quiz_question, quiz: allowed_quiz, question: allowed, position: 1)
    unallowed_quiz = create(:quiz)
    create(:quiz_question, quiz: unallowed_quiz, question: unallowed, position: 1)
    other_quiz = create(:quiz)
    create(:quiz_question, quiz: other_quiz, question: allowed, position: 1)
    create(:quiz_question, quiz: other_quiz, question: unallowed, position: 2)
    create(:quiz_question, quiz: other_quiz, question: other, position: 3)

    allowed_position = create(:position, :statuses => ['undergrad'], :quiz => allowed_quiz)
    unallowed_position_status = create(:position, :statuses => ['grad'], :quiz => unallowed_quiz)
    unallowed_position_membership_requestability = create(:position, :statuses => ['undergrad'], :quiz => unallowed_quiz)
    other_position = create(:position, :statuses => ['undergrad'], :quiz => other_quiz)

    committee = create(:committee)
    create(:enrollment, committee: committee, position: allowed_position, requestable: true)
    create(:enrollment, committee: committee, position: unallowed_position_status, requestable: true)
    create(:enrollment, committee: committee, position: unallowed_position_membership_requestability)
    committee.reload

    membership_request = build(:membership_request, :committee => committee, :user => user)
    membership_request.questions.length.should eql 1
    membership_request.questions.should include allowed
    @membership_request.questions.length.should eql 0
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

    short_quiz = create(:quiz)
    answered_questions.inject(1) do |i, question|
      create(:quiz_question, quiz: short_quiz, question: question, position: i)
      i + 1
    end
    full_quiz = create(:quiz)
    questions.inject(1) do |i, question|
      create(:quiz_question, quiz: full_quiz, question: question, position: i)
      i + 1
    end

    less_recent = generate_answered_membership_request user, short_quiz, 'less recent answer'
    sleep 1
    most_recent = generate_answered_membership_request user, short_quiz, 'most recent answer'

    membership_request = build(:membership_request, user: user, committee: create(:enrollment,
      position: create(:position, quiz: full_quiz), requestable: true).committee )
    a = membership_request.answers.build
    a.question = unanswered_local
    membership_request.answers.send(:populated_question_ids).size.should eql 1
    membership_request.answers.send(:populated_question_ids).should include unanswered_local.id
    answers = membership_request.answers.populate
    answers.length.should eql 3
    question_ids = answers.map { |answer| answer.question_id }
    question_ids.should include unanswered_global.id
    question_ids.should include answered_local.id
    question_ids.should include answered_global.id
    qa = membership_request.answers.inject({}) do |memo, answer|
      memo[answer.question] = answer.content
      memo
    end
    qa[unanswered_local].blank?.should be_true
    qa[unanswered_global].blank?.should be_true
    qa[answered_local].blank?.should be_true
    qa[answered_global].should eql 'most recent answer'
  end

  it  'should have a expired and unexpired scopes' do
    older = create(:expired_membership_request)
    old = create(:expired_membership_request, :ends_at => Date.today)
    @membership_request.ends_at.should > Date.today
    MembershipRequest.expired.length.should eql 2
    MembershipRequest.expired.should include older
    MembershipRequest.expired.should include old
    MembershipRequest.unexpired.length.should eql 1
    MembershipRequest.unexpired.should include @membership_request
  end

  it  'should claim unrequested memberships that the membership_request could apply to' do
    m = create(:membership)
    r = build(:membership_request, user: m.user)
    create(:enrollment, requestable: true, position: m.position, committee: r.committee)
#    r.stub!(:position_ids).and_return([m.position_id])
    r.save.should be_true
    r.memberships.size.should eql 1
    r.memberships.should include m
  end

  context 'rejection' do
    before(:each) do
      MembershipRequest.reject_notice_pending.length.should eql 0
      @admin = create(:user, admin: true)
      @authorized = create(:user)
      enrollment = create(:enrollment)
      @authority = @membership_request.authorities.first
      @authority.committee = enrollment.committee
      @authority.save.should be_true
      membership = create(:membership, :position => enrollment.position, :user => @authorized )
      @unauthorized = create(:user)
      @membership_request.rejected_by_user = @admin
      @membership_request.rejected_by_authority = @authority
      @membership_request.rejection_comment = 'a comment'
    end

    it  'should save with valid parameters from administrator' do
      @membership_request.reject!
    end

    it  'should save with valid parameters from authorized user for the authority' do
      @membership_request.rejected_by_user = @authorized
      @membership_request.reject!
    end

    it  'should not save with valid parameters from unauthorized user for the authority' do
      @membership_request.rejected_by_user = @unauthorized
      @membership_request.reject.should be_false
    end

    it  'should not save if rejected without a comment' do
      @membership_request.rejection_comment = nil
      @membership_request.reject.should be_false
    end

    it  'should have an unreject method that removes rejection status' do
      @membership_request.reject!
      @membership_request.reactivate.should be_true
      @membership_request.rejected?.should be_false
    end

    it  'should have a send_reject_notice! method which sends a rejection notice and saves' do
      @membership_request.reject!
      @membership_request.send_reject_notice!
      @membership_request.reload
      @membership_request.reject_notice_at.should_not be_nil
    end

    it 'should have a reject_notice_pending scope' do
      @membership_request.reject!
      MembershipRequest.reject_notice_pending.length.should eql 1
      @membership_request.send_reject_notice!
      MembershipRequest.reject_notice_pending.length.should eql 0
    end
  end

  it 'should have an interested_in that identifies membership_requests staffable to and temporily interested in a membership' do
    interested_in_scenario :position_statuses_mask => 1, :committee => true,
      :user_statuses_mask => 0, :membership_request_expired => false,
      :requestable_by_committee => true, :success => false
    interested_in_scenario :position_statuses_mask => 0, :committee => true,
      :user_statuses_mask => 0, :membership_request_expired => false,
      :requestable_by_committee => true, :success => true
    interested_in_scenario :position_statuses_mask => 0, :committee => true,
      :user_statuses_mask => 0, :membership_request_expired => false,
      :requestable_by_committee => false, :success => false
  end

  # Accepts attributes to allow testing for a variety of scenarios:
  # * requestable_by_committee: Is the position requestable by committee?
  # * position_statuses_mask: The mask of the position associated with the membership
  # * committee: Whether membership_request should be for committee instead of the position
  # * user_statuses_mask: The mask of the user making the membership_request
  # * membership_request_expired: Whether the membership_request coincides with the membership temporily
  # * success: Whether scope should return the membership_request or not
  def interested_in_scenario( params )
    position = create(:position)
    committee = create(:enrollment, position: position, requestable: true ).committee
    membership_request = create(:membership_request,
      user: create(:user, statuses_mask: params[:user_statuses_mask]),
      committee: committee )
    position.reload
    create(:period, schedule: position.schedule)
    membership = position.memberships.first
    membership.position_id.should eql position.id
    if params[:membership_request_expired]
      membership_request.ends_at = membership.starts_at - 1.day
      membership_request.starts_at = membership_request.ends_at - 1.year
    else
      membership_request.ends_at = membership.starts_at + 1.year
      membership_request.starts_at = membership_request.ends_at - 2.years
    end
    membership_request.save!
    committee.enrollments.first.update_attribute :requestable, params[:requestable_by_committee]
    position.update_attribute :statuses_mask, params[:position_statuses_mask]
#    scope = MembershipRequest.joins(:user).interested_in( membership ).uniq
    scope = membership.membership_requests.overlapping
    if params[:success]
      scope.length.should eql 1
      scope.should include membership_request
    else
      scope.length.should eql 0
    end
  end

  def generate_answered_membership_request(user, quiz, answer)
    membership_request = build(:membership_request, user: user, committee: create(:enrollment,
      position: create(:position, quiz: quiz), requestable: true).committee )
    quiz.questions.each do |question|
      a = membership_request.answers.build
      a.content = answer
      a.question = question
    end
    membership_request.save!
    membership_request
  end
end

