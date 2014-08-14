require 'spec_helper'

describe Motion, :type => :model do
  let(:motion) { build :motion }

  context 'validation' do

    it "should create a new instance given valid attributes" do
      motion.save!
    end

    it 'should not save without a name' do
      motion.name = nil
      expect(motion.save).to be false
    end

    it 'should not save with a duplicate name for given committee and period' do
      motion.save!
      duplicate = create( :motion, committee: motion.committee, period: motion.period )
      duplicate.name = motion.name
      expect(duplicate.save).to be false
    end

    it 'should not save without a period' do
      motion.period = nil
      expect(motion.save).to be false
    end

    it 'should not save with a period that is not in the schedule of the committee' do
      motion.period = create(:period)
      expect(motion.committee.schedule.periods).not_to include motion.period
      expect(motion.save).to be false
    end

    it 'should not save without a committee' do
      motion.committee = nil
      expect(motion.save).to be false
    end

  end

  context "position" do
    let(:motion) { create :motion }
    let(:past) { motion.committee.schedule.association(:periods).reset &&
      create( :past_period, schedule: motion.committee.schedule ) }

    it "should be 1 for the first item, 2 for the next" do
      expect(motion.position).to eql 1
      expect(create(:motion, committee: motion.committee, period: motion.period).position).to eql 2
    end

    it "should be 1 for a different period" do
      expect(create(:motion, committee: motion.committee, period: past).position).to eql 1
    end

    it "should reposition subsequent items for same committee/period on destroy" do
      create(:motion, committee: motion.committee, period: past)
      motions = 2.times.inject([]) do |memo|
        create(:motion, committee: motion.committee, period: past)
        memo << create(:motion, committee: motion.committee, period: motion.period)
      end
      expect(motions.map(&:position)).to eql [2,3]
      motions.first.destroy
      motions.last.reload
      expect(motions.last.position).to eql 2
      motion.reload
      expect(motion.position).to eql 1
      expect(motion.committee.motions.where { |m| m.period_id.eq( past.id ) }.
        value_of(:position)).to eql [1,2,3]
    end
  end

  context 'referred motions' do

    let(:motion) { create( :motion ) }

    def divided_motions
      divided = create(:motion)
      divided.propose!
      divided.motion_events.populate_for 'divide'
      2.times do |i|
        divided.referred_motions.build do |divisee|
          divisee.name = "Divided motion #{i}"
          divisee.description = "some description"
          divisee.content = "some content"
        end
      end
      divided.divide!
      expect(divided.referred_motions.length).to eql 2
      divided.referred_motions
    end

    def referee_motion
      referred = create(:motion)
      referred.propose!
      motion = referred.referred_motions.populate_referee
      motion.name = referred.name
      motion.committee = create(:committee, schedule: referred.committee.schedule)
      referred.refer!
      motion
    end

    let(:amendment) {  motion.referred_motions.populate_amendment true }

    it "should save ancestry for a referee motion" do
      expect(motion.parent).to eql motion.referring_motion
    end

    it 'should have a referee? method that indicates if it originates from a referred motion' do
      expect(motion.referee?).to be false
      divisee = divided_motions.first
      expect(divisee.referee?).to be false
      expect(divisee.referring_motion.referee?).to be false
      referee = referee_motion
      expect(referee.referee?).to be true
      expect(referee.referring_motion.referee?).to be false
    end

    it "should have a referred_motions.build_amendment method" do
      expect(amendment.name).to eql motion.amendable_name
      expect(amendment.content).to eql motion.content
      expect(amendment.committee).to eql motion.committee
      expect(amendment.period).to eql motion.period
    end

    it "should have a working build_amendment method" do
      motion.propose!
      expect(amendment.name).to eql "Amended #{motion.name} #1"
      expect(amendment.description).to eql motion.description
      expect(amendment.content).to eql motion.content
    end

    it "should apply adopted amendment changes to amended motion" do
      motion.propose!
      amendment.description = 'Different description'
      amendment.content = 'Different content'
      expect(motion.description).not_to eql amendment.description
      expect(motion.content).not_to eql amendment.content
      expect(motion.status).to eql 'proposed'
      motion.amend!
      motion.reload
      expect(motion.status).to eql 'amended'
    end

    it "should unamend a motion on reject" do
      motion.propose!
      amendment
      motion.amend!
      motion.reload
      expect(motion.status).to eql 'amended'
      amendment.reject!
      motion.reload
      expect(motion.status).to eql 'proposed'
    end

  end

  context 'users' do

    let(:motion) { create :motion }

    it 'should have a allowed which returns only users who may sponsor' do
      right_position = create( :position, schedule: motion.committee.schedule )
      wrong_position = create( :position, schedule: motion.committee.schedule )
      wrong_period = create(:period, schedule: motion.committee.schedule,
        starts_at: ( motion.period.ends_at + 1.day ) )
      create( :enrollment, position: right_position, committee: motion.committee )
      motion.committee.schedule.association(:periods).reset
      allowed_user = create( :membership, period: motion.period, position: right_position ).user
      wrong_period_user = create( :membership, period: wrong_period, position: right_position ).user
      wrong_committee_user = create( :membership, period: motion.period, position: wrong_position ).user
      motion.reload
      expect(motion.users.allowed).to include allowed_user
      expect(motion.users.allowed).not_to include wrong_period_user
      expect(motion.users.allowed).not_to include wrong_committee_user
      expect(motion.users.allowed.length).to eql 1
    end

  end

  context 'temporal scopes' do

    it 'should have a current scope that returns motions with a current period' do
      setup_temporal_motions
      expect(Motion.current.length).to eql 1
      expect(Motion.current).to include @current
    end

    it 'should have a past scope that returns motions with a past period' do
      setup_temporal_motions
      expect(Motion.past.length).to eql 1
      expect(Motion.past).to include @past
    end

    def setup_temporal_motions
      committee = create( :committee )
      current_period = create( :current_period, :schedule => committee.schedule )
      past_period = create( :past_period, :schedule => committee.schedule )
      committee.schedule.association(:periods).reset
      @current = create( :motion, :committee => committee, :period => current_period )
      @past = create( :motion, :committee => committee, :period => past_period )
    end

  end

  context "amendable_name" do
    let(:motion) { create :motion, name: 'Original' }

    it "should return first name if there is no conflict" do
      expect(motion.amendable_name).to eql 'Amended Original #1'
    end

    it "should return second name if there is a conflict" do
      create( :motion, committee: motion.committee, period: motion.period,
        name: motion.amendable_name )
      expect(motion.amendable_name).to eql 'Amended Original #2'
    end
  end
  
  context "scheduled/unscheduled scope" do
    let(:item) { create :motion_meeting_item }
    let(:motion) { item.motion }
    
    it "should have an unscheduled scope" do
      expect(Motion.unscheduled).to include motion
      item.meeting_section.meeting.update_column :starts_at, ( Time.zone.now + 2.days )
      expect(Motion.unscheduled).not_to include motion
    end
    
    it "should have a scheduled scope" do
      expect(Motion.scheduled).not_to include motion
      item.meeting_section.meeting.update_column :starts_at, ( Time.zone.now + 2.days )
      expect(Motion.scheduled).to include motion
    end
  end
end

