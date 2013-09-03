require 'spec_helper'

describe Motion do
  let(:motion) { build :motion }

  context 'validation' do

    it "should create a new instance given valid attributes" do
      motion.save!
    end

    it 'should not save without a name' do
      motion.name = nil
      motion.save.should be_false
    end

    it 'should not save with a duplicate name for given committee and period' do
      motion.save!
      duplicate = create( :motion, committee: motion.committee, period: motion.period )
      duplicate.name = motion.name
      duplicate.save.should be_false
    end

    it 'should not save without a period' do
      motion.period = nil
      motion.save.should be_false
    end

    it 'should not save with a period that is not in the schedule of the committee' do
      motion.period = create(:period)
      motion.committee.schedule.periods.should_not include motion.period
      motion.save.should be_false
    end

    it 'should not save without a committee' do
      motion.committee = nil
      motion.save.should be_false
    end

  end

  context "position" do
    let(:motion) { create :motion }
    let(:past) { motion.committee.schedule.association(:periods).reset &&
      create( :past_period, schedule: motion.committee.schedule ) }

    it "should be 1 for the first item, 2 for the next" do
      motion.position.should eql 1
      create(:motion, committee: motion.committee, period: motion.period).position.should eql 2
    end

    it "should be 1 for a different period" do
      create(:motion, committee: motion.committee, period: past).position.should eql 1
    end

    it "should reposition subsequent items for same committee/period on destroy" do
      create(:motion, committee: motion.committee, period: past)
      motions = 2.times.inject([]) do |memo|
        create(:motion, committee: motion.committee, period: past)
        memo << create(:motion, committee: motion.committee, period: motion.period)
      end
      motions.map(&:position).should eql [2,3]
      motions.first.destroy
      motions.last.reload
      motions.last.position.should eql 2
      motion.reload
      motion.position.should eql 1
      motion.committee.motions.where { |m| m.period_id.eq( past.id ) }.
        value_of(:position).should eql [1,2,3]
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
      divided.referred_motions.length.should eql 2
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
      motion.parent.should eql motion.referring_motion
    end

    it 'should have a referee? method that indicates if it originates from a referred motion' do
      motion.referee?.should be_false
      divisee = divided_motions.first
      divisee.referee?.should be_false
      divisee.referring_motion.referee?.should be_false
      referee = referee_motion
      referee.referee?.should be_true
      referee.referring_motion.referee?.should be_false
    end

    it "should have a referred_motions.build_amendment method" do
      amendment.name.should eql motion.amendable_name
      amendment.content.should eql motion.content
      amendment.committee.should eql motion.committee
      amendment.period.should eql motion.period
    end

    it "should have a working build_amendment method" do
      motion.propose!
      amendment.name.should eql "Amended #{motion.name} #1"
      amendment.description.should eql motion.description
      amendment.content.should eql motion.content
    end

    it "should apply adopted amendment changes to amended motion" do
      motion.propose!
      amendment.description = 'Different description'
      amendment.content = 'Different content'
      motion.description.should_not eql amendment.description
      motion.content.should_not eql amendment.content
      motion.status.should eql 'proposed'
      motion.amend!
      motion.reload
      motion.status.should eql 'amended'
    end

    it "should unamend a motion on reject" do
      motion.propose!
      amendment
      motion.amend!
      motion.reload
      motion.status.should eql 'amended'
      amendment.reject!
      motion.reload
      motion.status.should eql 'proposed'
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
      motion.users.allowed.should include allowed_user
      motion.users.allowed.should_not include wrong_period_user
      motion.users.allowed.should_not include wrong_committee_user
      motion.users.allowed.length.should eql 1
    end

  end

  context 'temporal scopes' do

    it 'should have a current scope that returns motions with a current period' do
      setup_temporal_motions
      Motion.current.length.should eql 1
      Motion.current.should include @current
    end

    it 'should have a past scope that returns motions with a past period' do
      setup_temporal_motions
      Motion.past.length.should eql 1
      Motion.past.should include @past
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
      motion.amendable_name.should eql 'Amended Original #1'
    end

    it "should return second name if there is a conflict" do
      create( :motion, committee: motion.committee, period: motion.period,
        name: motion.amendable_name )
      motion.amendable_name.should eql 'Amended Original #2'
    end
  end
  
  context "scheduled/unscheduled scope" do
    let(:item) { create :motion_meeting_item }
    let(:motion) { item.motion }
    
    it "should have an unscheduled scope" do
      Motion.unscheduled.should include motion
      item.meeting_section.meeting.update_column :starts_at, ( Time.zone.now + 2.days )
      Motion.unscheduled.should_not include motion
    end
    
    it "should have a scheduled scope" do
      Motion.scheduled.should_not include motion
      item.meeting_section.meeting.update_column :starts_at, ( Time.zone.now + 2.days )
      Motion.scheduled.should include motion
    end
  end
end

