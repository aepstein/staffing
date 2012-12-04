require 'spec_helper'

describe MotionEvent do

  let(:event) { build(:motion_event) }

  it "should save with valid attributes" do
    event.save!
  end

  it "should not save without a motion" do
    event.motion = nil
    event.save.should be_false
  end

  it "should not save without an occurrence" do
    event.occurrence = nil
    event.save.should be_false
  end

  it "should not save without an event" do
    event.event = nil
    event.save.should be_false
  end
end

