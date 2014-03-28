require 'spec_helper'

describe Position do

  let(:position) { build :position }

  context 'validations' do

    it "should create a new instance given valid attributes" do
      position.save!
    end

    it 'should not save without a name' do
      position.name = nil
      position.save.should be_false
    end

    it 'should not save with a duplicate name' do
      position.save!
      duplicate = build(:position, :name => position.name)
      duplicate.save.should be_false
    end

    it 'should not save without an authority' do
      position.authority = nil
      position.save.should be_false
    end

    it 'should not save without a quiz' do
      position.quiz = nil
      position.save.should be_false
    end

    it 'should not save without a schedule' do
      position.schedule = nil
      position.save.should be_false
    end

    it 'should not save without a number of slots specified' do
      position.slots = nil
      position.save.should be_false
      position.slots = ""
      position.save.should be_false
      position.slots = -1
      position.save.should be_false
    end

    it "should not save without valid minimum_slots" do
      position.minimum_slots = nil
      position.save.should be_false
      position.slots = 1
      position.minimum_slots = 2
      position.save.should be_false
    end

  end

  context 'unassigned memberships' do

    context 'single slot' do

      let(:period) { create(:period) }
      let(:position) { create(:position, schedule: period.schedule) }

      it 'should create unassigned shifts when it is created' do
        position.memberships.unassigned.count.should eql 1
        position.memberships.count.should eql 1
        position.memberships.each do |membership|
          membership.starts_at.should eql period.starts_at
          membership.ends_at.should eql period.ends_at
        end
      end

      it 'should create unassigned memberships when the period\'s minimum_slots are increased' do
        position.slots += 1
        position.minimum_slots += 1
        position.save!
        position.memberships.count.should eql 2
        position.memberships.each do |membership|
          membership.starts_at.should eql period.starts_at
          membership.ends_at.should eql period.ends_at
        end
      end

      it 'should delete unassigned memberships for an inactivated position' do
        position.active = false
        position.save!
        Membership.where( position_id: position.id ).should be_empty
      end

    end

    context 'two slot' do

      let(:period) { create(:period) }
      let(:position) { create(:position, schedule: period.schedule, minimum_slots: 2, slots: 3) }

      it 'should have a membership.vacancies_for_period' do
        m = position.memberships.build
        m.assign_attributes( { period: period, starts_at: period.starts_at + 2.days,
          ends_at: period.ends_at - 2.days, user: create(:user) } )
        m.save!
        m = position.memberships.build
        m.assign_attributes( { period: period, starts_at: period.starts_at,
          ends_at: period.ends_at - 1.days, user: create(:user) } )
        m.save!
        Membership.unassigned.delete_all
        vacancies = position.memberships.vacancies_for_period(period)
        vacancies.should eql [
          [period.starts_at, 1], [period.starts_at + 1.day, 1],
          [period.starts_at + 2.days, 0], [period.ends_at - 2.days, 0],
          [period.ends_at - 1.day, 1], [period.ends_at, 2]
        ]
      end

      it 'should delete unassigned memberships when period\'s minimum slots are decreased' do
        position.memberships.count.should eql 2
        position.minimum_slots -= 1
        position.save!
        position.memberships.unassigned.count.should eql position.memberships.count
        position.memberships.count.should eql position.minimum_slots
        position.memberships.each do |membership|
          membership.starts_at.should eql period.starts_at
          membership.ends_at.should eql period.ends_at
        end
        position.memberships.count.should eql 1
      end

      it 'should not delete assigned memberships when period slots are decreased' do
        first = position.memberships.first
        first.user = create(:user)
        first.save.should eql true
        position.slots -= 1
        position.minimum_slots -= 1
        position.save!
        position.memberships.size.should eql 1
        position.memberships.should include first
      end

    end

  end

  context 'equivalent_committees_with scope' do

    let(:committee) { create( :enrollment, position: position ).committee }
    let(:position) { create(:position) }

    it "should include self equivalent" do
      Position.equivalent_committees_with(position).should include position
    end

    it "should include other with same committees equivalent" do
      other_position = create( :enrollment, committee: committee ).position
      Position.equivalent_committees_with(position).should include position, other_position
    end

    it "should exclude other without its committee" do
      other_position = create( :position )
      committee
      Position.equivalent_committees_with(position).should_not include other_position
    end

    it "should exclude other with committee it does not have" do
      other_position = create( :enrollment ).position
      Position.equivalent_committees_with(position).should_not include other_position
    end

    it "should exclude other if neither has committees" do
      other_position = create( :position )
      Position.equivalent_committees_with(position).should_not include other_position
    end

  end

end

