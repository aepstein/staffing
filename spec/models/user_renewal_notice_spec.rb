require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserRenewalNotice do
  before(:each) do
    @notice = Factory(:user_renewal_notice)
  end

  it 'should save with valid attributes' do
    @notice.id.should_not be_nil
  end

  it 'should not save without starts_at' do
    @notice.starts_at = nil
    @notice.save.should be_false
  end

  it 'should not save without ends_at' do
    @notice.ends_at = nil
    @notice.save.should be_false
  end

  it 'should not save with ends_at before or at starts_at' do
    @notice.ends_at = @notice.starts_at
    @notice.save.should be_false
    @notice.ends_at = @notice.starts_at - 1.day
    @notice.save.should be_false
  end

  it 'should not save with deadline before or at starts_at' do
    @notice.deadline = @notice.starts_at
    @notice.save.should be_false
    @notice.deadline = @notice.starts_at - 1.day
    @notice.save.should be_false
  end

end

