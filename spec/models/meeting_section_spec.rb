require 'spec_helper'

describe MeetingSection do

  let(:meeting_section) { build :meeting_section }

  context "validations" do
    it "should save with valid attributes" do
      meeting_section.save!
    end

    it "should not save without a name" do
      meeting_section.name = nil
      meeting_section.save.should be_false
    end

    it "should not save with a duplicate name" do
      meeting_section.save!
      duplicate = build(:meeting_section, name: meeting_section.name,
        meeting: meeting_section.meeting)
      duplicate.save.should be_false
    end
  end

end

