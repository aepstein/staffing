require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Membership do
  before(:each) do
    @membership = Factory(:membership)
  end

  it 'should create a new instance given valid attributes' do
    @membership.id.should_not be_nil
  end

  it 'should not save without a period' do
    @membership.period = nil
    @membership.save.should be_false
  end

  it 'should not save without a position' do
    @membership.position = nil
    @membership.save.should be_false
  end

  it 'should not save without a start date' do
    @membership.starts_at = nil
    @membership.save.should be_false
  end

  it 'should not save with a start date before the period start date' do
    @membership.starts_at = (@membership.period.starts_at - 1.day)
    @membership.save.should be_false
  end

  it 'should not save without an end date' do
    @membership.ends_at = nil
    @membership.save.should be_false
  end

  it 'should not save with an end date that is after the period end date' do
    @membership.ends_at = (@membership.period.ends_at + 1.day)
    @membership.save.should be_false
  end

  it 'should not save with an end date that is before the start date' do
    @membership.ends_at = (@membership.starts_at - 1.day)
    @membership.save.should be_false
  end

  it 'should not save with an unqualified user' do
    @membership.position.qualifications << Factory(:qualification)
    @membership.user = Factory(:user)
    @membership.user.qualifications.should_not include @membership.position.qualifications.first
    @membership.save.should eql false
  end

  it 'should save with a qualified user' do
    @membership.position.qualifications << Factory(:qualification)
    @membership.user = Factory(:user)
    @membership.position.qualifications.each { |q| @membership.user.qualifications << q }
    @membership.save.should eql true
  end

  it 'should populate a membership from a request' do
    request = Factory(:request)
    period = Factory(:period, :schedule => request.requestable.schedule, :starts_at => request.starts_at, :ends_at => request.ends_at)
    membership = Membership.new
    membership.request_id = request.id
    membership.period.should eql period
    membership.starts_at.should eql period.starts_at
    membership.ends_at.should eql period.ends_at
    membership.user.should eql membership.request.user
    membership.position.should eql membership.request.requestable
  end

  it 'should detect concurrent assigned memberships and prevent overstaffing' do
    assigned = setup_membership_with_vacancies
    second = Factory( :membership, :starts_at => assigned.starts_at + 1.days,
      :ends_at => assigned.ends_at - 1.days, :position => assigned.position,
      :period => assigned.period, :user => Factory(:user) )
    assigned.reload
    over = Factory.build(:membership, :starts_at => assigned.starts_at,
      :ends_at => assigned.ends_at, :position => assigned.position,
      :period => assigned.period, :user => Factory(:user) )
    counts = over.concurrent_counts
    counts[0].should eql [assigned.starts_at, 1]
    counts[1].should eql [second.starts_at, 2]
    counts[2].should eql [second.ends_at, 2]
    counts[3].should eql [assigned.ends_at, 1]
    counts.size.should eql 4
    over.save.should eql false
  end

  it 'should generate unassigned memberships when an assigned membership is created' do
    assigned = setup_membership_with_vacancies
    assigned.position.memberships.count.should eql 2
    assigned.position.memberships.should include assigned
    assigned.position.memberships.unassigned.count.should eql 1
    assigned.position.memberships.unassigned.first.id.should > assigned.id
  end

  it 'should regenerate unassigned memberships when an assigned membership is altered' do
    assigned = setup_membership_with_vacancies
    unassigned = assigned.position.memberships.unassigned.first
    assigned.ends_at -= 1.days
    assigned.save
    assigned.position.memberships.count.should eql 3
    assigned.position.memberships.should include assigned
    assigned.position.memberships.unassigned.count.should eql 2
  end

  it 'should regenerate unassigned memberships when an assigned membership is destroyed' do
    assigned = setup_membership_with_vacancies
    assigned.destroy
    assigned.position.memberships.count.should eql 2
    assigned.position.memberships(true).should_not include assigned
    assigned.position.memberships.unassigned.count.should eql 2
    assigned.position.memberships.unassigned.each { |m| m.id.should > assigned.id }
  end

  it 'should not regenerate unassigned membership when an assigned membership is destroyed if the position is inactive' do
    assigned = setup_membership_with_vacancies
    position = assigned.position
    position.active = false
    position.save!
    assigned.destroy
    position.memberships.reset
    position.memberships.unassigned.length.should eql 0
  end

  it 'should have a designees.populate method that creates a designee for each committee corresponding position is enrolled in' do
    @membership.position.update_attribute :designable, true
    enrollment_existing_designee = Factory(:enrollment, :position => @membership.position)
    enrollment_no_designee = Factory(:enrollment, :position => @membership.position)
    irrelevant_enrollment = Factory(:enrollment)
    irrelevant_enrollment.position.should_not eql @membership.position
    designee = Factory(:designee, :membership => @membership, :committee => enrollment_existing_designee.committee)
    @membership.designees.reload
    @membership.designees.size.should eql 1
    new_designees = @membership.designees.populate
    new_designees.size.should eql 1
    new_designees.first.committee.should eql enrollment_no_designee.committee
  end

  it 'should have a renewable scope that fetches only if the associated position is renewable, end date is same as period end date, and the period is current or immediately before current' do
    position = Factory(:position, :slots => 2, :renewable => true)
    current = Factory(:membership, :position => position)
    current_truncated = Factory(:membership, :position => position, :period => current.period, :ends_at => current.period.ends_at - 1.day)
    current_period = current.period
    prior_period = Factory(:period, :schedule => current.period.schedule,
      :starts_at => ( current_period.starts_at - 1.year ),
      :ends_at => ( current_period.starts_at - 1.day ) )
    prior = Factory(:membership, :position => position,
      :period => prior_period )
    ancient_period = Factory(:period, :schedule => current.period.schedule,
      :starts_at => ( prior_period.starts_at - 1.year ),
      :ends_at => ( prior_period.starts_at - 1.day ) )
    ancient = Factory(:membership, :position => position,
      :period => ancient_period )
    future_period = Factory(:future_period, :schedule => ancient_period.schedule)
    future = Factory(:membership, :position => position, :period => future_period)
    scope = Membership.renewable
    scope.should include current
    scope.should include prior
    Membership.renewable.uniq.length.should eql 2
  end

  it 'should have an unrenewable scope that fetches only if the associated position is renewable' do
    renewable = Factory(:membership, :position => renewable_position)
    Membership.unrenewable.length.should eql 1
    Membership.unrenewable.should include @membership
  end

  it 'should have an unrequested scope' do
    requested = Factory(:membership, :request => Factory(:request) )
    Membership.unrequested.size.should eql 1
    Membership.unrequested.should include @membership
  end

  it 'should claim a request for the user and position if the position is requestable' do
    nr_position = Factory(:position, :requestable => false, :requestable_by_committee => true)
    r_position = Factory(:position, :requestable => true)
    r_c_position = Factory(:position, :requestable_by_committee => true)
    r_committee = Factory(:committee, :requestable => true)
    Factory(:enrollment, :position => r_c_position, :committee => r_committee )
    Factory(:enrollment, :position => nr_position, :committee => r_committee )
    p_request = Factory(:request, :requestable => r_position)
    c_request = Factory(:request, :requestable => r_c_position)
    m = Factory(:membership, :position => r_position, :user => p_request.user)
    m.request.should eql p_request
    m.request.closed?.should be_true
    m = Factory(:membership, :position => r_c_position, :user => c_request.user)
    m.request.should eql c_request
    m.request.closed?.should be_true
    m = Factory(:membership, :position => nr_position, :user => c_request.user)
    m.request.should be_nil
  end

  it 'should have a notifiable scope that returns only memberships with users and notifiable position' do
    notifiable_scenario
    Membership.notifiable.length.should eql 1
    Membership.notifiable.should include @focus_membership
    Membership.count.should eql 4
  end

  it 'should have a join_notice_pending scope that returns only memberships that are awaiting join notice' do
    notifiable_scenario
    Membership.join_notice_pending.length.should eql 1
    Membership.join_notice_pending.should include @focus_membership
    @focus_membership.join_notice_at = Time.zone.now
    @focus_membership.save!
    Membership.join_notice_pending.length.should eql 0
  end

  it 'should have a leave_notice_pending scope that returns only memberships that are awaiting leave notice' do
    notifiable_scenario Date.today - 1.year, Date.today - 1.day
    Membership.leave_notice_pending.length.should eql 1
    Membership.leave_notice_pending.should include @focus_membership
    @focus_membership.leave_notice_at = Time.zone.now
    @focus_membership.save!
    Membership.leave_notice_pending.length.should eql 0
  end

  it 'should have a send_join_notice! method' do
    @membership.send_join_notice!
    @membership.reload
    @membership.join_notice_at.should_not be_nil
  end

  it 'should have a send_leave_notice! method' do
    @membership.send_leave_notice!
    @membership.reload
    @membership.leave_notice_at.should_not be_nil
  end

  it 'should not save with an invalid renew_until value' do
    @membership.renew_until = @membership.ends_at
    @membership.save.should be_false
    @membership.renew_until = 'coriander'
    @membership.save.should be_false
  end

  it 'should have renewed and unrenewed scopes based on renewed_by_membership_id flag' do
    future = Factory(:future_period, :schedule => @membership.position.schedule)
    renewed = Factory(:membership, :position => @membership.position,
      :user => @membership.user, :period => future)
    @membership.update_attribute :renewed_by_membership_id, renewed.id
    Membership.renewed.length.should eql 1
    Membership.renewed.should include @membership
    Membership.unrenewed.length.should eql 1
    Membership.unrenewed.should include renewed
  end

  it 'should have a renewable_to scope that returns memberships that a membership may renew' do
    renewable_to_scenario
    scope = Membership.renewable_to @membership
    scope.should include @same_position
    scope.should include @same_committee
    scope.uniq.length.should eql 2
  end

  it 'should claim renewed_memberships which are in renewable_to scope and match user_id' do
    renewable_to_scenario
    @same_position.user.should_not eql @same_committee.user
    @membership.user = @same_position.user
    @membership.save!
    @membership.renewed_memberships.length.should eql 1
    @membership.renewed_memberships.should include @same_position
    @membership.user = @same_committee.user
    @membership.save!
    @membership.renewed_memberships.length.should eql 1
    @membership.renewed_memberships.should include @same_committee
  end

  it 'should have a watchers method that returns users with overlapping, concurrent enrollment with membership_notices flag set' do
    position = @membership.position
    past_period = Factory(:past_period, :schedule => position.schedule)
    @membership.reload
    enrollment = Factory(:enrollment, :position => position)
    committee = enrollment.committee
    watcher_position = Factory(:position, :schedule => position.schedule)
    Factory(:enrollment, :position => watcher_position, :committee => committee, :membership_notices => true)
    watcher_membership = Factory(:membership, :position => watcher_position, :period => @membership.period)
    past_watcher_membership = Factory(:membership, :position => watcher_position, :period => past_period)
    nonwatcher_position = Factory(:enrollment, :committee => committee).position
    nonwatcher_membership = Factory(:membership, :position => nonwatcher_position)
    @membership.watchers.length.should eql 1
    @membership.watchers.should include watcher_membership.user
  end

  it 'should clear membership notices if user is blank' do
    @membership.update_attribute :join_notice_at, Time.zone.now
    @membership.update_attribute :leave_notice_at, Time.zone.now
    @membership.user = nil
    @membership.save!
    @membership.user_id.should be_nil
    @membership.join_notice_at.should be_nil
    @membership.leave_notice_at.should be_nil
  end

  def renewable_to_scenario
    past = Factory(:past_period, :schedule => @membership.position.schedule)
    @same_position = Factory(:membership, :position => @membership.position,
      :period => past, :renew_until => Time.zone.today + 1.week )
    @same_position.user.update_attribute :statuses_mask, 1
    @membership.update_attribute :user, nil
    @membership.position.update_attribute :statuses_mask, 1
    @same_committee = Factory(:past_membership, :renew_until => Time.zone.today + 1.week )
    @same_committee.user.update_attribute :statuses_mask, 1
    different_mask = Factory(:past_membership, :renew_until => Time.zone.today + 1.week )
    different_mask.user.update_attribute :statuses_mask, 2
    enrollment = Factory(:enrollment, :position => @membership.position)
    Factory(:enrollment, :position => @same_committee.position, :committee => enrollment.committee)
    Factory(:enrollment, :position => different_mask.position, :committee => enrollment.committee)
    different_position = Factory(:past_membership, :renew_until => Time.zone.today + 1.week)
  end

  def notifiable_scenario(starts_at = nil, ends_at = nil)
    starts_at ||= Date.today - 1.year
    ends_at ||= starts_at + 2.years
    Membership.delete_all
    schedule = Factory(:period, :starts_at => starts_at, :ends_at => ends_at).schedule
    focus_position = Factory(:position, :notifiable => true, :slots => 2, :schedule => schedule)
    other_position = Factory(:position, :slots => 2, :schedule => schedule)
    @focus_membership = Factory(:membership, :position => focus_position, :user => Factory(:user) )
    Factory(:membership, :position => other_position, :user => Factory(:user) )
  end

  def renewable_position
    Factory(:position, :renewable => true)
  end

  def subsequent_membership(membership)
    subsequent = membership.clone
    subsequent.period = Factory(:period, :schedule => subsequent.position.schedule, :starts_at => membership.ends_at + 1.day,
      :ends_at => membership.ends_at + 1.day + 1.year)
    subsequent.starts_at = subsequent.period.starts_at
    subsequent.ends_at = subsequent.period.ends_at
    subsequent.save.should be_true
    subsequent
  end

  def setup_membership_with_vacancies
    period = Factory(:period, :schedule => Factory(:schedule) )
    position = Factory(:position, :schedule => period.schedule, :slots => 2)
    membership = position.memberships.build
    membership.user = Factory(:user)
    membership.period = period
    membership.starts_at = period.starts_at
    membership.ends_at = period.ends_at
    membership.save!
    position.memberships.unassigned.length.should eql 1
    position.memberships.assigned.length.should eql 1
    membership
  end
end

