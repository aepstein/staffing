require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Request do
  before(:each) do
    @request = Factory(:request)
  end

  it "should create a new instance given valid attributes" do
    @request.id.should_not be_nil
  end

  it 'should not save without a start date' do
    @request.starts_at = nil
    @request.save.should be_false
  end

  it 'should not save without an end date' do
    @request.ends_at = nil
    @request.save.should be_false
  end

  it 'should not save with an end date that is before the start date' do
    @request.ends_at = @request.starts_at
    @request.save.should be_false
  end

  it 'should not save without a requestable' do
    @request.requestable = nil
    @request.save.should be_false
  end

  it 'should not save without a user' do
    @request.user = nil
    @request.save.should be_false
  end

  it 'should not save if for a position and the user does not meet status requirements of the position' do
    @request.requestable.statuses = ['undergrad']
    @request.requestable.save
    @request.user.status.should_not eql 'undergrad'
    @request.save.should be_false
  end
end

