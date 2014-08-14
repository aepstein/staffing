require 'spec_helper'

describe MotionMeetingSegment, :type => :model do
  let(:motion_meeting_segment) { build :motion_meeting_segment }

  it "should save with valid attributes" do
    motion_meeting_segment.save!
  end
end

