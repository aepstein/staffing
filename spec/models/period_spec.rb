require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Period do
  before(:each) do
    @period = Factory(:period)
  end

  it "should create a new instance given valid attributes" do
    @period.id.should_not be_nil
  end

  it 'should not save without a start date' do
    @period.starts_at = nil
    @period.save.should be_false
  end

  it 'should not save without an end date' do
    @period.ends_at = nil
    @period.save.should be_false
  end

  it 'should not save with an end date that is before the start date' do
    @period.ends_at = @period.starts_at - 1.day
    @period.save.should be_false
  end

  it 'should not save if it conflicts with another period in the same schedule' do
    conflict = Factory.build(:period, :schedule => @period.schedule,
      :ends_at => @period.starts_at + 1.day, :starts_at => @period.starts_at - 1.day)
    @period.starts_at.should <= conflict.ends_at
    @period.ends_at.should >= conflict.starts_at
    conflict.save.should be_false
  end

  it 'should reallocate start and end dates of memberships that are out of new bounds' do
    original_start = @period.starts_at
    original_end = @period.ends_at
    position = Factory(:position, :schedule => @period.schedule, :slots => 3)
    first = position.memberships[0]
    second = position.memberships[1]
    third = position.memberships[2]
    first.user = Factory(:user)
    first.save.should eql true
    second.user = Factory(:user)
    second.starts_at = original_start + 2.days
    second.save!
    @period.starts_at += 1.day
    @period.ends_at -= 1.day
    @period.save
    @period.memberships.reload
    @period.memberships.should_not include third
    @period.memberships.should include first
    @period.memberships.should include second
    @period.memberships.count.should eql 4
    first.reload
    first.starts_at.should eql original_start + 1.day
    first.ends_at.should eql original_end - 1.day
    second.reload
    second.starts_at.should eql original_start + 2.days
    second.ends_at.should eql original_end - 1.day
  end

  it 'should populate unassiged memberships for associated positions' do
    position = Factory(:position)
    @period = Factory(:period, :schedule => position.schedule)
    @period.memberships.count.should eql 1
    @period.memberships.unassigned.count.should eql 1
  end

  it 'should not populate unassigned memberships for associated inactive positions' do
    position = Factory(:position, :active => false)
    @period = Factory(:period, :schedule => position.schedule)
    @period.memberships.should be_empty
  end

  it 'should have a to_range method' do
    @period.starts_at = '2010-01-01'
    @period.ends_at = '2011-01-01'
    @period.to_range.should eql( @period.starts_at..@period.ends_at )
  end
end

