require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Request do
  before(:each) do
    @request = Factory(:request)
  end

  it "should create a new instance given valid attributes" do
    @request.id.should_not be_nil
  end

  it 'should not save without any periods specified' do
    @request.periods = []
    @request.save.should be_false
  end

  it 'should not save without a position' do
    @request.position = nil
    @request.save.should be_false
  end

  it 'should not save without a user' do
    @request.user = nil
    @request.save.should be_false
  end

  it 'should not save if the user does not meet status requirements of the position' do
    @request.position.statuses = ['undergrad']
    @request.position.save
    @request.user.status.should_not eql 'undergrad'
    @request.save.should be_false
  end
end

