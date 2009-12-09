require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Authority do
  before(:each) do
    @authority = Factory(:authority)
  end

  it "should create a new instance given valid attributes" do
    @authority.id.should_not be_nil
  end

  it 'should not save without a name' do
    @authority.name = nil
    @authority.save.should eql false
  end

  it 'should not save with a duplicate name' do
    duplicate = Factory.build(:authority)
    duplicate.name = @authority.name
    duplicate.save.should eql false
  end
end

