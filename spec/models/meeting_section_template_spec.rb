require 'spec_helper'

describe MeetingSectionTemplate, :type => :model do
  let(:meeting_section_template) { build :meeting_section_template }

  it "should save with valid attributes" do
    meeting_section_template.save!
  end

  it "should not save without a meeting template" do
    meeting_section_template.meeting_template = nil
    expect(meeting_section_template.save).to be false
  end

  it "should not save without a name" do
    meeting_section_template.name = nil
    expect(meeting_section_template.save).to be false
  end

  it "should not save without a position or with invalid position" do
    meeting_section_template.position = nil
    expect(meeting_section_template.save).to be false
    meeting_section_template.position = 0
    expect(meeting_section_template.save).to be false
  end

  it "should not save with a duplicate name" do
    meeting_section_template.save!
    duplicate = build( :meeting_section_template,
      meeting_template: meeting_section_template.meeting_template,
      name: meeting_section_template.name )
    expect(duplicate.save).to be false
  end

  context "populable attributes" do

    let(:meeting_section_template) { create :meeting_section_template }
    let(:populable_attributes) { meeting_section_template.populable_attributes }

    it "should return expected values" do
      expect(meeting_section_template.populable_attributes).to eql(
        { name: meeting_section_template.name,
          position: meeting_section_template.position } )
    end
  end

end

