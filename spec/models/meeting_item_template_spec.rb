require 'spec_helper'

describe MeetingItemTemplate do
  let(:meeting_item_template) { build :meeting_item_template }

  it "should save with valid attributes" do
    meeting_item_template.save!
  end

  it "should not save without a meeting section template" do
    meeting_item_template.meeting_section_template = nil
    meeting_item_template.save.should be_false
  end

  it "should not save without a name" do
    meeting_item_template.name = nil
    meeting_item_template.save.should be_false
  end

  it "should not save with a duplicate name" do
    meeting_item_template.save!
    duplicate = build( :meeting_item_template,
      name: meeting_item_template.name,
      meeting_section_template: meeting_item_template.meeting_section_template )
    duplicate.save.should be_false
  end

  it "should not save without a position or with invalid position" do
    meeting_item_template.position = nil
    meeting_item_template.save.should be_false
    meeting_item_template.position = 0
    meeting_item_template.save.should be_false
  end

  it "should not save with invalid duration" do
    meeting_item_template.duration = 0
    meeting_item_template.save.should be_false
  end
end
