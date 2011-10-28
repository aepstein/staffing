require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Membership do
  before(:each) do
    @designee = create(:designee)
  end

  it 'should save with valid attributes' do
    @designee.id.should_not be_nil
  end

  it 'should not save without a membership' do
    @designee.membership = nil
    @designee.save.should be_false
  end

  it 'should not save without a committee' do
    @designee.committee = nil
    @designee.save.should be_false
  end

  it 'should not save without a user' do
    @designee.user = nil
    @designee.save.should be_false
  end

  it 'should not save for a non-designable position' do
    @designee.membership.position.update_attribute( :designable, false )
    @designee.save.should be_false
  end

  it 'should not save with a duplicate for any membership and committee combination' do
    @duplicate = build(:designee, :membership => @designee.membership, :committee => @designee.committee)
    @duplicate.save.should be_false
  end

  it 'should not save with a committee if the membership\'s position is not enrolled in that committee' do
    committee = create(:committee)
    committee.positions.except(:order).should_not include @designee.membership.position
    @designee.committee = committee
    @designee.save.should be_false
  end
end

