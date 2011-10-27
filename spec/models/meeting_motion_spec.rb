require 'spec_helper'

describe MeetingMotion do
  before(:each) do
    @meeting_motion = create(:meeting_motion)
  end

  it 'should save with valid attributes' do
    @meeting_motion.id.should_not be_nil
  end

  it 'should not save without a meeting' do
    @meeting_motion.meeting = nil
    @meeting_motion.save.should be_false
  end

  it 'should not save without a motion' do
    @meeting_motion.motion = nil
    @meeting_motion.save.should be_false
  end

  it 'should not save a duplicate motion for a given meeting' do
    duplicate = build( :meeting_motion, :meeting => @meeting_motion.meeting, :motion => @meeting_motion.motion )
    duplicate.save.should be_false
  end

  it 'should not save a motion that is not in meeting.motions.allowed' do
    @meeting_motion.meeting.motions.stub(:allowed).and_return([])
    @meeting_motion.save.should be_false
  end

end

