require 'spec_helper'

describe MeetingSection, :type => :model do

  let(:meeting_section) { build :meeting_section }

  context "validations" do
    it "should save with valid attributes" do
      meeting_section.save!
    end

    it "should not save without a name" do
      meeting_section.name = nil
      expect(meeting_section.save).to be false
    end

    it "should not save with a duplicate name" do
      meeting_section.save!
      duplicate = build(:meeting_section, name: meeting_section.name,
        meeting: meeting_section.meeting)
      expect(duplicate.save).to be false
    end
  end

end

