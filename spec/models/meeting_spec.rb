require 'spec_helper'

describe Meeting, :type => :model do
  before(:each) do
    @meeting = create(:meeting)
  end

  it "should create a new instance given valid attributes" do
    expect(create(:meeting).id).not_to be_nil
  end

  it 'should not save without a committee' do
    @meeting.committee = nil
    expect(@meeting.save).to be false
  end

  it 'should not save without a period' do
    @meeting.period = nil
    expect(@meeting.save).to be false
  end

  it 'should not save without starts_at' do
    @meeting.starts_at = nil
    expect(@meeting.save).to be false
  end

  it 'should not save with a duration or with an invalid duration' do
    @meeting.duration = nil
    expect(@meeting.save).to be false
    @meeting.duration = 0
    expect(@meeting.save).to be false
  end

  it 'should not save without a location' do
    @meeting.location = nil
    expect(@meeting.save).to be false
  end

  it 'should not save with a period from a different schedule than that of committee' do
    @meeting.period = create(:period)
    @meeting.starts_at = @meeting.period.starts_at.to_time + 1.hour
    expect(@meeting.save).to be false
  end

  it 'should not save with a starts_at outside the period' do
    @meeting.starts_at = @meeting.period.starts_at.to_time - 1.day
    expect(@meeting.save).to be false
    @meeting.starts_at = @meeting.period.ends_at.to_time + 1.day
    expect(@meeting.save).to be false
  end

  it 'should have a past scope' do
    setup_past_and_future
    expect(Meeting.past.count).to eql 1
    expect(Meeting.past).to include @past
  end

  it 'should have a current scope' do
    setup_past_and_future
    expect(Meeting.current.count).to eql 1
    expect(Meeting.current).to include @meeting
  end

  it 'should have a future scope' do
    setup_past_and_future
    expect(Meeting.future.count).to eql 1
    expect(Meeting.future).to include @future
  end

  it 'should have motions.allowed that returns only matching committee and period of meeting' do
    allowed = create(:motion, :committee => @meeting.committee, :period => @meeting.period)
    same_period = create(:motion, :committee => create(:committee, :schedule => @meeting.committee.schedule), :period => @meeting.period )
    new_period = create( :period, :schedule => @meeting.period.schedule, :starts_at => ( @meeting.period.ends_at + 1.day ) )
    @meeting.reload
    same_committee = create(:motion, :committee => @meeting.committee, :period => new_period )
    expect(same_period.period).to eql @meeting.period
    expect(same_period.committee).not_to eql @meeting.committee
    expect(same_committee.committee).to eql @meeting.committee
    expect(same_committee.period).not_to eql @meeting.period
    expect(@meeting.motions.allowed.count).to eql 1
    expect(@meeting.motions.allowed).to include allowed
    expect(@meeting.motions.allowed).not_to include same_period
    expect(@meeting.motions.allowed).not_to include same_committee
  end

  context "meeting sections" do
    let(:meeting_template) { create(:meeting_item_template, duration: 100,
      description: 'unusual').meeting_section_template.meeting_template }
    let(:meeting) { create(:meeting, committee: create( :committee, meeting_template: meeting_template )) }

    context "populate" do
      it "should populate a meeting's sections if it is empty" do
        meeting.meeting_sections.populate
        meeting.save!
        section = meeting.meeting_sections.first
        section_template = meeting_template.meeting_section_templates.first
        expect(section.name).to eql section_template.name
        expect(section.position).to eql section_template.position
        item = section.meeting_items.first
        item_template = section_template.meeting_item_templates.first
        expect(item.name).to eql item_template.name
        expect(item.duration).to eql item_template.duration
        expect(item.description).to eql item_template.description
        expect(item.position).to eql item_template.position
      end

      it "should not populate if the meeting already has a section" do
        section = meeting.meeting_sections.build name: 'Unusual Structure', position: 1
        meeting.meeting_sections.populate
        meeting.save!
        expect(meeting.meeting_sections.length).to eql 1
        expect(meeting.meeting_sections).to include section
        expect(section.name).to eql 'Unusual Structure'
        expect(section.meeting_items).to be_empty
      end
    end
  end

  def setup_past_and_future
    @meeting.starts_at = Time.zone.now
    @meeting.save!
    @past = create(:meeting, starts_at: Time.zone.now - 1.week)
    @future = create(:meeting, starts_at: Time.zone.now + 1.week)
  end
end

