require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Membership, :type => :model do
  before(:each) do
    @designee = create(:designee)
  end

  it 'should save with valid attributes' do
    expect(@designee.id).not_to be_nil
  end

  it 'should not save without a membership' do
    @designee.membership = nil
    expect(@designee.save).to be false
  end

  it 'should not save without a committee' do
    @designee.committee = nil
    expect(@designee.save).to be false
  end

  it 'should not save without a user' do
    @designee.user = nil
    expect(@designee.save).to be false
  end

  it 'should not save for a non-designable position' do
    @designee.membership.position.update_attribute( :designable, false )
    expect(@designee.save).to be false
  end

  it 'should not save with a duplicate for any membership and committee combination' do
    @duplicate = build(:designee, :membership => @designee.membership, :committee => @designee.committee)
    expect(@duplicate.save).to be false
  end

  it 'should not save with a committee if the membership\'s position is not enrolled in that committee' do
    committee = create(:committee)
    expect(committee.positions.except(:order)).not_to include @designee.membership.position
    @designee.committee = committee
    expect(@designee.save).to be false
  end
end

