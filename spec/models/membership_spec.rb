require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Membership do
  before(:each) do
    @membership = Factory(:membership)
  end

  it "should create a new instance given valid attributes" do
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

  it 'should detect concurrent assigned memberships and prevent overstaffing' do
    @membership.position.slots = 2
    @membership.position.save.should eql true
    second = Factory( :membership, :starts_at => @membership.starts_at + 1.day,
      :ends_at => @membership.ends_at - 1.day, :position => @membership.position,
      :period => @membership.period )
    overlaps = Membership.overlap(@membership.starts_at,@membership.ends_at).position_id_eq(@membership.position_id)
    overlaps.should include @membership
    overlaps.should include second
    overlaps.size.should eql 2
    over = Factory.build(:membership, :starts_at => @membership.starts_at,
      :ends_at => @membership.ends_at, :position => @membership.position,
      :period => @membership.period )
    counts = over.concurrent_membership_counts
    counts[@membership.starts_at].should eql 2
    counts[second.starts_at].should eql 3
    counts[second.ends_at].should eql 3
    counts[@membership.ends_at].should eql 2
    counts.size.should eql 4
    over.save.should eql false
  end

  it 'should populate a membership from a request' do
    membership = Membership.new( :request_id => Factory(:request).id )
    membership.period.should eql membership.request.periods.first
    membership.starts_at.should eql membership.period.starts_at
    membership.ends_at.should eql membership.period.ends_at
    membership.user.should eql membership.request.user
    membership.position.should eql membership.request.position
  end

  it 'should regenerate assigned memberships when a membership is created' do
    assigned = setup_membership_with_vacancies
    assigned.position.memberships.count.should eql 2
    assigned.position.memberships.should include assigned
    assigned.position.memberships.unassigned.count.should eql 1
    assigned.position.memberships.unassigned.first.id.should > assigned.id
  end

  it 'should regenerate assigned memberships when a membership is altered' do
    assigned = setup_membership_with_vacancies
    unassigned = assigned.position.memberships.unassigned.first
    assigned.ends_at -= 1.days
    assigned.save
    assigned.position.memberships.count.should eql 3
    assigned.position.memberships.should include assigned
    assigned.position.memberships.unassigned.count.should eql 2
  end

  it 'should regenerate assigned memberships when an assigned membership is destroyed' do
    assigned = setup_membership_with_vacancies
    assigned.destroy
    assigned.position.memberships.count.should eql 2
    assigned.position.memberships(true).should_not include assigned
    assigned.position.memberships.unassigned.count.should eql 2
    assigned.position.memberships.unassigned.each { |m| m.id.should > assigned.id }
  end

  def setup_membership_with_vacancies
    period = Factory(:period, :schedule => Factory(:schedule) )
    position = Factory(:position, :schedule => period.schedule, :slots => 2)
    position.memberships.create( :user => Factory(:user), :period => period,
      :starts_at => period.starts_at, :ends_at => period.ends_at )
  end
end

