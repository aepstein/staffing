require 'spec_helper'

describe Motion do
  before(:each) do
    @motion = Factory(:motion)
  end

  it "should create a new instance given valid attributes" do
    @motion.id.should_not be_nil
  end

  it 'should not save without a name' do
    @motion.name = nil
    @motion.save.should be_false
  end

  it 'should not save with a duplicate name for given committee and period' do
    @duplicate = Factory( :motion, :user => @motion.user,
      :committee => @motion.committee, :period => @motion.period )
    @duplicate.name = @motion.name
    @duplicate.save.should be_false
  end

  it 'should not save without a period' do
    @motion.period = nil
    @motion.save.should be_false
  end

  it 'should not save with a period that is not in the schedule of the committee' do
    @motion.period = Factory(:period)
    @motion.committee.schedule.periods.should_not include @motion.period
    @motion.save.should be_false
  end

  it 'should not save without a user' do
    @motion.user = nil
    @motion.save.should be_false
  end

  it 'should not save without a committee' do
    @motion.committee = nil
    @motion.save.should be_false
  end
end

