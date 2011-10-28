require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Position do
  before(:each) do
    @position = create(:position)
  end

  it "should create a new instance given valid attributes" do
    @position.id.should_not be_nil
  end

  it 'should not save without a name' do
    @position.name = nil
    @position.save.should be_false
  end

  it 'should not save with a duplicate name' do
    duplicate = build(:position, :name => @position.name)
    duplicate.save.should be_false
  end

  it 'should not save without an authority' do
    @position.authority = nil
    @position.save.should be_false
  end

  it 'should not save without a quiz' do
    @position.quiz = nil
    @position.save.should be_false
  end

  it 'should not save without a schedule' do
    @position.schedule = nil
    @position.save.should be_false
  end

  it 'should not save without a number of slots specified' do
    @position.slots = nil
    @position.save.should be_false
    @position.slots = ""
    @position.save.should be_false
    @position.slots = -1
    @position.save.should be_false
  end

  it 'should have a requestable_by_committee scope' do
    @position.requestable_by_committee.should eql false
    focus = create(:position, :requestable_by_committee => true)
    Position.requestable_by_committee.length.should eql 1
    Position.requestable_by_committee.should include focus
  end

  it 'should have a membership.vacancies_for_period' do
    @position.slots = 2
    @position.save!
    period = create(:period, :schedule => @position.schedule)
    m = @position.memberships.build
    m.assign_attributes( { :period => period, :starts_at => period.starts_at + 2.days,
      :ends_at => period.ends_at - 2.days, :user => create(:user) },
      without_protection: true )
    m.save!
    m = @position.memberships.build
    m.assign_attributes( { :period => period, :starts_at => period.starts_at,
      :ends_at => period.ends_at - 1.days, :user => create(:user) },
      without_protection: true )
    m.save!
    Membership.unassigned.delete_all
    vacancies = @position.memberships.vacancies_for_period(period)
    vacancies.should eql [
      [period.starts_at, 1], [period.starts_at + 1.day, 1],
      [period.starts_at + 2.days, 0], [period.ends_at - 2.days, 0],
      [period.ends_at - 1.day, 1], [period.ends_at, 2]
    ]
  end

  it 'should create unassigned shifts when it is created' do
    period = position_with_period
    @position.memberships.unassigned.count.should eql @position.memberships.count
    @position.memberships.count.should eql @position.slots
    @position.memberships.each do |membership|
      membership.starts_at.should eql period.starts_at
      membership.ends_at.should eql period.ends_at
    end
  end

  it 'should create unassigned shifts when the period\'s slots are increased' do
    period = position_with_period
    @position.slots = ( @position.slots + 1 )
    @position.slots_was.should_not eql @position.slots
    @position.save!
    @position.memberships.unassigned.count.should eql @position.memberships.count
    @position.memberships.count.should eql @position.slots
    @position.memberships.each do |membership|
      membership.starts_at.should eql period.starts_at
      membership.ends_at.should eql period.ends_at
    end
  end

  it 'should delete unassigned shifts when period\'s slots are decreased' do
    period = position_with_period(2)
    @position.memberships.count.should eql 2
    @position.slots -= 1
    @position.save!
    @position.memberships.unassigned.count.should eql @position.memberships.count
    @position.memberships.count.should eql @position.slots
    @position.memberships.each do |membership|
      membership.starts_at.should eql period.starts_at
      membership.ends_at.should eql period.ends_at
    end
    @position.memberships.count.should eql 1
  end

  it 'should not delete assigned shifts when period slots are decreased' do
    period = position_with_period(2)
    first = @position.memberships.first
    first.user = create(:user)
    first.save.should eql true
    @position.slots -= 1
    @position.save!
    @position.memberships.size.should eql 1
    @position.memberships.should include first
  end

  it 'should delete memberships for an inactivated position' do
    @position.active = false
    @position.save!
    Membership.where( :position_id => @position.id ).should be_empty
  end

  def position_with_period(slots=1)
    period = create(:period)
    @position = create(:position, :schedule => period.schedule, :slots => slots)
    period
  end
end

