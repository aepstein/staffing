require 'spec_helper'

describe MotionEvent, :type => :model do

  let(:event) { build(:motion_event) }

  it "should save with valid attributes" do
    event.save!
  end

  it "should not save without a motion" do
    event.motion = nil
    expect(event.save).to be false
  end

  it "should not save without an occurrence" do
    event.occurrence = nil
    expect(event.save).to be false
  end

  it "should not save without an event" do
    event.event = nil
    expect(event.save).to be false
  end

  it "should not save with an occurrence before the motion's period start" do
    event.occurrence = event.motion.period.starts_at - 1.day
    expect(event.save).to be false
  end

  it "should not save with an occurrence after today" do
    event.occurrence = Time.zone.today + 1.day
    expect(event.save).to be false
  end
end

