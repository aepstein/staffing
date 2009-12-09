require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @user = Factory(:user)
  end

  it "should create a new instance given valid attributes" do
    @user.id.should_not be_nil
  end

  it 'should not save without a net_id' do
    @user.net_id.should_not be_nil
  end

  it 'should not save with a duplicate net_id' do
    duplicate = Factory.build(:user)
    duplicate.net_id = @user.net_id
    duplicate.save.should be_false
  end

  it 'should not save without a first name' do
    @user.first_name = nil
    @user.save.should be_false
  end

  it 'should not save without a last name' do
    @user.last_name = nil
    @user.save.should be_false
  end

  it 'should not save without email' do
    @user.email = nil
    @user.save.should be_false
  end

end

