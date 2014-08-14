require 'spec_helper'

describe Position, :type => :model do

  let(:position) { build :position }

  context 'validations' do

    it "should create a new instance given valid attributes" do
      position.save!
    end

    it 'should not save without a name' do
      position.name = nil
      expect(position.save).to be false
    end

    it 'should not save with a duplicate name' do
      position.save!
      duplicate = build(:position, :name => position.name)
      expect(duplicate.save).to be false
    end

    it 'should not save without an authority' do
      position.authority = nil
      expect(position.save).to be false
    end

    it 'should not save without a quiz' do
      position.quiz = nil
      expect(position.save).to be false
    end

    it 'should not save without a schedule' do
      position.schedule = nil
      expect(position.save).to be false
    end

    it 'should not save without a number of slots specified' do
      position.slots = nil
      expect(position.save).to be false
      position.slots = ""
      expect(position.save).to be false
      position.slots = -1
      expect(position.save).to be false
    end

    it "should not save without valid minimum_slots" do
      position.minimum_slots = nil
      expect(position.save).to be false
      position.slots = 1
      position.minimum_slots = 2
      expect(position.save).to be false
    end

  end

  context 'unassigned memberships' do

    context 'single slot' do

      let(:period) { create(:period) }
      let(:position) { create(:position, schedule: period.schedule) }

      it 'should create unassigned shifts when it is created' do
        expect(position.memberships.unassigned.count).to eql 1
        expect(position.memberships.count).to eql 1
        position.memberships.each do |membership|
          expect(membership.starts_at).to eql period.starts_at
          expect(membership.ends_at).to eql period.ends_at
        end
      end

      it 'should create unassigned memberships when the period\'s minimum_slots are increased' do
        position.slots += 1
        position.minimum_slots += 1
        position.save!
        expect(position.memberships.count).to eql 2
        position.memberships.each do |membership|
          expect(membership.starts_at).to eql period.starts_at
          expect(membership.ends_at).to eql period.ends_at
        end
      end

      it 'should delete unassigned memberships for an inactivated position' do
        position.active = false
        position.save!
        expect(Membership.where( position_id: position.id )).to be_empty
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
        expect(vacancies).to eql [
          [period.starts_at, 1], [period.starts_at + 1.day, 1],
          [period.starts_at + 2.days, 0], [period.ends_at - 2.days, 0],
          [period.ends_at - 1.day, 1], [period.ends_at, 2]
        ]
      end

      it 'should delete unassigned memberships when period\'s minimum slots are decreased' do
        expect(position.memberships.count).to eql 2
        position.minimum_slots -= 1
        position.save!
        expect(position.memberships.unassigned.count).to eql position.memberships.count
        expect(position.memberships.count).to eql position.minimum_slots
        position.memberships.each do |membership|
          expect(membership.starts_at).to eql period.starts_at
          expect(membership.ends_at).to eql period.ends_at
        end
        expect(position.memberships.count).to eql 1
      end

      it 'should not delete assigned memberships when period slots are decreased' do
        first = position.memberships.first
        first.user = create(:user)
        expect(first.save).to eql true
        position.slots -= 1
        position.minimum_slots -= 1
        position.save!
        expect(position.memberships.size).to eql 1
        expect(position.memberships).to include first
      end

    end

  end

  context 'equivalent_committees_with scope' do

    let(:committee) { create( :enrollment, position: position ).committee }
    let(:position) { create(:position) }

    it "should include self equivalent" do
      expect(Position.equivalent_committees_with(position)).to include position
    end

    it "should include other with same committees equivalent" do
      other_position = create( :enrollment, committee: committee ).position
      expect(Position.equivalent_committees_with(position)).to include position, other_position
    end

    it "should exclude other without its committee" do
      other_position = create( :position )
      committee
      expect(Position.equivalent_committees_with(position)).not_to include other_position
    end

    it "should exclude other with committee it does not have" do
      other_position = create( :enrollment ).position
      expect(Position.equivalent_committees_with(position)).not_to include other_position
    end

    it "should exclude other if neither has committees" do
      other_position = create( :position )
      expect(Position.equivalent_committees_with(position)).not_to include other_position
    end

  end

end

