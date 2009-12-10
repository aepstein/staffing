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
end

