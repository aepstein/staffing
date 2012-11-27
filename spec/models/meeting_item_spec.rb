require 'spec_helper'

describe MeetingItem do
  let( :meeting_item ) { build :meeting_item }

  context "validations" do
    it "should save with valid attributes" do
      meeting_item.save!
    end

    it "should not save without a name" do
      meeting_item.name = nil
      meeting_item.save.should be_false
    end

    it "should not save with a duplicate name" do
      meeting_item.save!
      duplicate = build(:meeting_item,
        meeting_section: meeting_item.meeting_section,
        name: meeting_item.name)
    end

    it "should not save without a duration" do
      meeting_item.duration = nil
      meeting_item.save.should be_false
      meeting_item.duration = 0
      meeting_item.save.should be_false
    end
  end

end

