require 'spec_helper'

describe Sponsorship do
  before(:each) do
    @sponsorship = create(:sponsorship)
  end

  it 'should save with valid attributes' do
    @sponsorship.id.should_not be_nil
  end

  it 'should not save without a motion' do
    @sponsorship.motion = nil
    @sponsorship.save.should be_false
  end

  it 'should not save without a user' do
    @sponsorship.user = nil
    @sponsorship.save.should be_false
  end

  it 'should not save a duplicate for given motion and user' do
    duplicate = build( :sponsorship, :motion => @sponsorship.motion,
      :user => @sponsorship.user )
    duplicate.save.should be_false
  end

  it 'should not save for user who is not in motion.users.allowed' do
    @sponsorship.motion.users.stub(:allowed).and_return([])
    @sponsorship.save.should be_false
  end
end

