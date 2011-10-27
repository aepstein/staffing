require 'spec_helper'

describe Meeting do
  before(:each) do
    @meeting = create(:meeting)
  end

  it "should create a new instance given valid attributes" do
    create(:meeting).id.should_not be_nil
  end

  it 'should not save without a committee' do
    @meeting.committee = nil
    @meeting.save.should be_false
  end

  it 'should not save without a period' do
    @meeting.period = nil
    @meeting.save.should be_false
  end

  it 'should not save without starts_at' do
    @meeting.starts_at = nil
    @meeting.save.should be_false
  end

  it 'should not save with a ends_at' do
    @meeting.ends_at = nil
    @meeting.save.should be_false
  end

  it 'should not save without a location' do
    @meeting.location = nil
    @meeting.save.should be_false
  end

  it 'should not save with a period from a different schedule than that of committee' do
    @meeting.period = create(:period)
    @meeting.starts_at = @meeting.period.starts_at.to_time + 1.hour
    @meeting.ends_at = @meeting.starts_at + 1.hour
    @meeting.save.should be_false
  end

  it 'should not save with a starts_at outside the period' do
    @meeting.starts_at = @meeting.period.starts_at.to_time - 1.day
    @meeting.save.should be_false
    @meeting.starts_at = @meeting.period.ends_at.to_time + 1.day
    @meeting.save.should be_false
  end

  it 'should not save with a ends_at outside the period' do
    @meeting.ends_at = @meeting.period.starts_at.to_time - 1.day
    @meeting.save.should be_false
    @meeting.ends_at = @meeting.period.ends_at.to_time + 1.day
    @meeting.save.should be_false
  end

  it 'should not save with ends_at equal to or before starts_at' do
    @meeting.ends_at = @meeting.starts_at
    @meeting.save.should be_false
    @meeting.ends_at = @meeting.starts_at - 1.minute
    @meeting.save.should be_false
  end

  it 'should have a past scope' do
    setup_past_and_future
    Meeting.past.count.should eql 1
    Meeting.past.should include @past
  end

  it 'should have a current scope' do
    setup_past_and_future
    Meeting.current.count.should eql 1
    Meeting.current.should include @meeting
  end

  it 'should have a future scope' do
    setup_past_and_future
    Meeting.future.count.should eql 1
    Meeting.future.should include @future
  end

  it 'should have motions.allowed that returns only matching committee and period of meeting' do
    allowed = create(:motion, :committee => @meeting.committee, :period => @meeting.period)
    same_period = create(:motion, :committee => create(:committee, :schedule => @meeting.committee.schedule), :period => @meeting.period )
    new_period = create( :period, :schedule => @meeting.period.schedule, :starts_at => ( @meeting.period.ends_at + 1.day ) )
    @meeting.reload
    same_committee = create(:motion, :committee => @meeting.committee, :period => new_period )
    same_period.period.should eql @meeting.period
    same_period.committee.should_not eql @meeting.committee
    same_committee.committee.should eql @meeting.committee
    same_committee.period.should_not eql @meeting.period
    @meeting.motions.allowed.count.should eql 1
    @meeting.motions.allowed.should include allowed
    @meeting.motions.allowed.should_not include same_period
    @meeting.motions.allowed.should_not include same_committee
  end

  def setup_past_and_future
    @meeting.starts_at = Time.zone.now
    @meeting.ends_at = Time.zone.now + 1.hour
    @meeting.save!
    @past = create(:meeting, :starts_at => Time.zone.now - 1.week)
    @future = create(:meeting, :starts_at => Time.zone.now + 1.week)
  end
end

