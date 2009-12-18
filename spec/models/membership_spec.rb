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

  it 'should detect concurrent memberships and prevent overstaffing' do
    @membership.position.slots = 2
    @membership.position.save.should eql true
    second = Factory( :membership, :starts_at => @membership.starts_at + 1.day,
      :ends_at => @membership.ends_at - 1.day, :position => @membership.position,
      :period => @membership.period )
    overlaps = Membership.overlaps(@membership.starts_at,@membership.ends_at).position_id_eq(@membership.position_id)
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
end

