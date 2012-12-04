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

    it "should not save with an event date before period start" do
      motion.event_date = motion.period.starts_at - 1.day
      motion.save.should be_false
    end

    it "should not save with an event date after today" do
      motion.event_date = Time.zone.today + 1.day
      motion.save.should be_false
    end

    it "should not save with an invalid event date" do
      motion.event_date = 'blah'
      motion.save.should be_false
    end

  end

  context 'referred motions' do

    let(:motion) { create( :motion ) }

    def divided_motions
      divided = create(:motion)
      divided.propose!
      2.times do |i|
        divided.referred_motions.build do |divisee|
          divisee.name = "Divided motion #{i}"
          divisee.content = "some content"
          divisee.committee = divided.committee
          divisee.published = true
          divisee.period = divided.period
        end
      end
      divided.divide!
      divided.referred_motions.length.should eql 2
      divided.referred_motions
    end

    def referee_motion
      referred = create(:motion)
      referred.propose!
      motion = referred.referred_motions.build_referee(
        committee_name: create(:committee, schedule: referred.committee.schedule ).name
      )
      motion.save!
      motion
    end

    let(:amendment) {  motion.referred_motions.build_amendment }

    it 'should have a referee? method that indicates if it originates from a referred motion' do
      motion.referee?.should be_false
      divisee = divided_motions.first
      divisee.referee?.should be_false
      divisee.referring_motion.referee?.should be_false
      referee = referee_motion
      referee.referee?.should be_true
      referee.referring_motion.referee?.should be_false
    end

    it "should have a working build_amendment method" do
      motion.propose!
      amendment.name.should eql "Amend #{motion.name} #1"
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
      amendment.adopt!
      motion.reload
      motion.status.should eql 'proposed'
      motion.description.should eql amendment.description
      motion.content.should eql amendment.content
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
      motion.amendable_name.should eql 'Amend Original #1'
    end

    it "should return second name if there is a conflict" do
      create( :motion, committee: motion.committee, period: motion.period,
        name: motion.amendable_name )
      motion.amendable_name.should eql 'Amend Original #2'
    end
  end

  context "amended motion" do
    let(:motion) { create(:motion) }

    it "should have a referred_motions.build_amendment method" do
      amendment = motion.referred_motions.build_amendment
      amendment.name.should eql motion.amendable_name
      amendment.content.should eql motion.content
      amendment.committee.should eql motion.committee
      amendment.period.should eql motion.period
      motion.amendment.should eql amendment
    end
  end

end

