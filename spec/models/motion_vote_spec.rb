require 'spec_helper'

describe MotionVote, :type => :model do
  let(:motion_vote) { build :motion_vote }
  
  it "should save with valid attributes" do
    motion_vote.save!
  end
  
  it "should not save without a motion event" do
    motion_vote.motion_event = nil
    expect(motion_vote.save).to be false
  end
  
  it "should not save without a user" do
    motion_vote.user = nil
    expect(motion_vote.save).to be false
  end
  
  it "should not save with a user who is not in the motion event users" do
    good_membership = motion_vote.motion_event.memberships.first
    position = good_membership.position
    prior = create :period, schedule: position.schedule,
      starts_at: good_membership.starts_at - 1.year,
      ends_at: good_membership.starts_at - 1.day
    bad_membership = create :membership, position: position, period: prior
    motion_vote.user = bad_membership.user
    expect(motion_vote.save).to be false
  end
end
