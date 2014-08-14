require 'spec_helper'

describe MeetingItemTemplate, :type => :model do
  let(:meeting_item_template) { build :meeting_item_template }

  it "should save with valid attributes" do
    meeting_item_template.save!
  end

  it "should not save without a meeting section template" do
    meeting_item_template.meeting_section_template = nil
    expect(meeting_item_template.save).to be false
  end

  it "should not save without a name" do
    meeting_item_template.name = nil
    expect(meeting_item_template.save).to be false
  end

  it "should not save with a duplicate name" do
    meeting_item_template.save!
    duplicate = build( :meeting_item_template,
      name: meeting_item_template.name,
      meeting_section_template: meeting_item_template.meeting_section_template )
    expect(duplicate.save).to be false
  end

  it "should not save without a position or with invalid position" do
    meeting_item_template.position = nil
    expect(meeting_item_template.save).to be false
    meeting_item_template.position = 0
    expect(meeting_item_template.save).to be false
  end

  it "should not save with invalid duration" do
    meeting_item_template.duration = 0
    expect(meeting_item_template.save).to be false
  end

  context "populable attributes" do

    let(:meeting_item_template) { create( :meeting_item_template,
      duration: 100, description: 'a special item' ) }
    let(:populable_attributes) { meeting_item_template.populable_attributes }

    it "should return expected values" do
      expect(meeting_item_template.populable_attributes).to eql(
       { name: meeting_item_template.name,
         duration: meeting_item_template.duration,
         description: meeting_item_template.description,
         position: meeting_item_template.position } )
    end
  end

end

