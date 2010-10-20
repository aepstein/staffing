require 'spec_helper'

describe Meeting do
  before(:each) do
    @meeting = Factory(:meeting)
  end

  it "should create a new instance given valid attributes" do
    Factory(:meeting).id.should_not be_nil
  end

  it 'should not save without a committee' do
    @meeting.committee = nil
    @meeting.save.should be_false
  end

  it 'should not save without a period' do
    @meeting.period = nil
    @meeting.save.should be_false
  end

  it 'should not save with a period from a different schedule than that of committee' do
    @meeting.period = Factory(:period)
    @meeting.when_scheduled = @meeting.period.starts_at
    @meeting.save.should be_false
  end

  it 'should not save with a date outside the period' do
    @meeting.when_scheduled = @meeting.period.starts_at - 1.day
    @meeting.save.should be_false
  end

  it 'should not save without a when_scheduled date' do
    @meeting.when_scheduled = nil
    @meeting.save.should be_false
  end
end

