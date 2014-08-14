require 'spec_helper'

describe MeetingTemplate, :type => :model do

  let(:meeting_template) { build :meeting_template }

  it "should save with valid attributes" do
    meeting_template.save!
  end

  it "should not save without a name" do
    meeting_template.name = nil
    expect(meeting_template.save).to be false
  end

  it "should not save with a duplicate name" do
    meeting_template.save!
    duplicate = build(:meeting_template, name: meeting_template.name)
    expect(duplicate.save).to be false
  end

end

