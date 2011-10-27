require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Schedule do
  before(:each) do
    @schedule = create(:schedule)
  end

  it "should create a new instance given valid attributes" do
    @schedule.id.should_not be_nil
  end

  it 'should not save without a name' do
    @schedule.name = nil
    @schedule.save.should eql false
  end

  it 'should not save with a duplicate name' do
    duplicate = build(:schedule)
    duplicate.name = @schedule.name
    duplicate.save.should eql false
  end
end

