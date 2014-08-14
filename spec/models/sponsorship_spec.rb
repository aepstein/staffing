require 'spec_helper'

describe Sponsorship, :type => :model do
  before(:each) do
    @sponsorship = create(:sponsorship)
  end

  it 'should save with valid attributes' do
    expect(@sponsorship.id).not_to be_nil
  end

  it 'should not save without a motion' do
    @sponsorship.motion = nil
    expect(@sponsorship.save).to be false
  end

  it 'should not save without a user' do
    @sponsorship.user = nil
    expect(@sponsorship.save).to be false
  end

  it 'should not save a duplicate for given motion and user' do
    duplicate = build( :sponsorship, :motion => @sponsorship.motion,
      :user => @sponsorship.user )
    expect(duplicate.save).to be false
  end

  it 'should not save for user who is not in motion.users.allowed' do
#    @sponsorship.motion.users.stub(:allowed).and_return([])
    users = double("UsersProxy")
    allow(users).to receive(:allowed) { [] }
    allow(@sponsorship.motion).to receive(:users) { users }
    expect(@sponsorship.save).to be false
  end
end

