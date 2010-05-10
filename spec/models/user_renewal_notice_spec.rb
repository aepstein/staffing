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

  it 'should have a users method that returns users who are candidates for sendings' do
    eligible_users = [ eligible_user ]
    notice = Factory(:user_renewal_notice, :starts_at => eligible_users.first.memberships.first.starts_at,
      :ends_at => eligible_users.first.memberships.first.ends_at )
    ineligible_users = [ ]
    # Recently received sending
    ineligible_users << eligible_user
    Factory(:sending, :user => ineligible_users.last)
    # Renewed membership
    ineligible_users << eligible_user
    user = ineligible_users.last
    membership = user.memberships.first
    period = Factory(:period, :schedule => membership.position.schedule, :starts_at => membership.ends_at + 1.day)
    Factory(:membership, :user => user, :position => membership.position, :period => period)
    # Unrenewable membership
    ineligible_users << eligible_user
    position = ineligible_users.last.memberships.first.position
    position.renewable = false
    position.save
    # Starts before starts_at
    position = Factory(:position)
    period = Factory(:past_period, :schedule => position.schedule)
    ineligible_users << Factory(:membership, :period => period, :position => position).user
    # Ends after ends_at
    position = Factory(:position)
    period = Factory(:future_period, :schedule => position.schedule)
    ineligible_users << Factory(:membership, :period => period, :position => position).user
    notice_users = notice.users
    notice_users.should include eligible_users.first
    ineligible_users.each do |ineligible|
      notice_users.should_not include ineligible
    end
  end

  it 'should have a sendings.populate method that populates from the users method' do
    allowed = Factory(:user)
    disallowed = Factory(:user)
    @notice.stub!(:users).and_return([allowed])
    @notice.sendings.populate
    @notice.sendings.length.should eql 1
    @notice.sendings.first.user.should eql allowed
  end

  def eligible_user
    Factory(:membership, :position => Factory(:position, :renewable => true) ).user
  end

end

