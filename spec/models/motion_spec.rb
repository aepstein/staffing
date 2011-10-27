require 'spec_helper'

describe Motion do
  before(:each) do
    @motion = create(:motion)
  end

  it "should create a new instance given valid attributes" do
    @motion.id.should_not be_nil
  end

  it 'should not save without a name' do
    @motion.name = nil
    @motion.save.should be_false
  end

  it 'should not save with a duplicate name for given committee and period' do
    @duplicate = create( :motion, :committee => @motion.committee, :period => @motion.period )
    @duplicate.name = @motion.name
    @duplicate.save.should be_false
  end

  it 'should not save without a period' do
    @motion.period = nil
    @motion.save.should be_false
  end

  it 'should not save with a period that is not in the schedule of the committee' do
    @motion.period = create(:period)
    @motion.committee.schedule.periods.should_not include @motion.period
    @motion.save.should be_false
  end

  it 'should not save without a committee' do
    @motion.committee = nil
    @motion.save.should be_false
  end

  it 'should change status to referred when referred motion is created' do
    @motion.propose!
    referee = @motion.referred_motions.build_referee(
      create(:committee, :schedule => @motion.committee.schedule )
    )
    referee.save!
    @motion.reload
    @motion.status.should eql 'referred'
  end

  it 'should create divided motions when divide! is called' do
    @motion.propose!
    @motion.divide!
    @motion.status.should eql 'divided'
    @motion.referred_motions.length.should eql 2
  end

  it 'should have a referred? method that indicates if it is referred' do
    @motion.referred?.should be_false
    referee = referee_motion
    referee.referred?.should be_false
    referee.referring_motion.referred?.should be_true
    divisee = divided_motions.first
    divisee.referred?.should be_false
    divisee.referring_motion.referred?.should be_false
  end

  it 'should have a divided? method that indicates if it is divided' do
    @motion.divided?.should be_false
    divisee = divided_motions.first
    divisee.reload
    divisee.divided?.should be_false
    divisee.referring_motion.divided?.should be_true
    referee = referee_motion
    referee.divided?.should be_false
    referee.referring_motion.divided?.should be_false
  end

  it 'should have a referee? method that indicates if it originates from a referred motion' do
    @motion.referee?.should be_false
    divisee = divided_motions.first
    divisee.referee?.should be_false
    divisee.referring_motion.referee?.should be_false
    referee = referee_motion
    referee.referee?.should be_true
    referee.referring_motion.referee?.should be_false
  end

  it 'should have a divisee? method that indicates if it originates from a divided motion' do
    @motion.divisee?.should be_false
    divisee = divided_motions.first
    divisee.divisee?.should be_true
    divisee.referring_motion.divisee?.should be_false
    referee = referee_motion
    referee.divisee?.should be_false
    referee.referring_motion.divisee?.should be_false
  end

  it 'should have a users.allowed which returns only users who may sponsor' do
    right_position = create( :position, :schedule => @motion.committee.schedule )
    wrong_position = create( :position, :schedule => @motion.committee.schedule )
    wrong_period = create(:period, :schedule => @motion.committee.schedule,
      :starts_at => ( @motion.period.ends_at + 1.day ) )
    create( :enrollment, :position => right_position, :committee => @motion.committee )
    allowed_user = create( :membership, :period => @motion.period, :position => right_position ).user
    wrong_period_user = create( :membership, :period => wrong_period, :position => right_position ).user
    wrong_committee_user = create( :membership, :period => @motion.period, :position => wrong_position ).user
    @motion.reload
    @motion.users.allowed.should include allowed_user
    @motion.users.allowed.should_not include wrong_period_user
    @motion.users.allowed.should_not include wrong_committee_user
    @motion.users.allowed.length.should eql 1
  end

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
    Motion.delete_all
    committee = create( :committee )
    @current = create( :motion, :committee => committee, :period => create( :current_period, :schedule => committee.schedule ) )
    @past = create( :motion, :committee => committee, :period => create( :past_period, :schedule => committee.schedule ) )
  end

  def divided_motions
    divided = create(:motion)
    divided.propose!
    divided.divide!
    divided.referred_motions.length.should eql 2
    divided.referred_motions
  end

  def referee_motion
    referred = create(:motion)
    referred.propose!
    motion = referred.referred_motions.build_referee(
      create(:committee, :schedule => referred.committee.schedule )
    )
    motion.save!
    motion
  end
end

