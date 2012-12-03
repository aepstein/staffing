require 'spec_helper'

describe MeetingTemplate do

  let(:meeting_template) { build :meeting_template }

  it "should save with valid attributes" do
    meeting_template.save!
  end

  it "should not save without a name" do
    meeting_template.name = nil
    meeting_template.save.should be_false
  end

  it "should not save with a duplicate name" do
    meeting_template.save!
    duplicate = build(:meeting_template, name: meeting_template.name)
    duplicate.save.should be_false
  end

end

