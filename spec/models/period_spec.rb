require 'spec_helper'

describe Period, :type => :model do

  let(:period) { build :period }

  it 'should have a to_range method' do
    period.starts_at = '2010-01-01'
    period.ends_at = '2011-01-01'
    expect(period.to_range).to eql( period.starts_at..period.ends_at )
  end

  context 'validation' do

    it "should create a new instance given valid attributes" do
      period.save!
    end

    it 'should not save without a start date' do
      period.starts_at = nil
      expect(period.save).to be false
    end

    it 'should not save without an end date' do
      period.ends_at = nil
      expect(period.save).to be false
    end

    it 'should not save with an end date that is before the start date' do
      period.ends_at = period.starts_at - 1.day
      expect(period.save).to be false
    end

    it 'should not save if it conflicts with another period in the same schedule' do
      period.save!
      conflict = build(:period, :schedule => period.schedule,
        :ends_at => period.starts_at + 1.day, :starts_at => period.starts_at - 1.day)
      expect(period.starts_at).to be <= conflict.ends_at
      expect(period.ends_at).to be >= conflict.starts_at
      expect(conflict.save).to be false
    end

  end

  context 'recent scope' do

    let(:future_period) { create :period, schedule: period.schedule,
      starts_at: period.ends_at + 1.day,
      ends_at: period.ends_at +  1.year - 1.day }
    let(:period) { create :period }
    let(:past_period) { create :period, schedule: period.schedule,
      starts_at: period.starts_at - 1.year,
      ends_at: period.starts_at - 1.day }
    let(:ancient_period)  { create :period, schedule: period.schedule,
      starts_at: past_period.starts_at - 1.year,
      ends_at: past_period.starts_at - 1.day }

    it "should include current and past periods only" do
      expect(Period.recent).to include period, past_period
      expect(Period.recent).not_to include future_period, ancient_period
    end

  end

  context 'membership population' do

    it 'should reallocate start and end dates of memberships that are out of new bounds' do
      period = create :period
      original_start = period.starts_at
      original_end = period.ends_at
      position = create(:position, :schedule => period.schedule, :slots => 3)
      first = position.memberships[0]
      second = position.memberships[1]
      third = position.memberships[2]
      first.user = create(:user)
      expect(first.save).to eql true
      second.user = create(:user)
      second.starts_at = original_start + 2.days
      second.save!
      period.starts_at += 1.day
      period.ends_at -= 1.day
      period.save
      period.association(:memberships).reset
      expect(period.memberships).not_to include third
      expect(period.memberships).to include first
      expect(period.memberships).to include second
      expect(period.memberships.count).to eql 4
      expect(period.memberships.unassigned.as_of(period.starts_at).count).to eql 2
      expect(period.memberships.unassigned.as_of(period.ends_at).count).to eql 1
      first.reload
      expect(first.starts_at).to eql original_start + 1.day
      expect(first.ends_at).to eql original_end - 1.day
      second.reload
      expect(second.starts_at).to eql original_start + 2.days
      expect(second.ends_at).to eql original_end - 1.day
    end

    it 'should populate unassiged memberships for associated positions' do
      position = create(:position)
      period = create(:period, :schedule => position.schedule)
      expect(period.memberships.count).to eql 1
      expect(period.memberships.unassigned.count).to eql 1
    end

    it 'should not populate unassigned memberships for associated inactive positions' do
      position = create(:position, :active => false)
      period = create(:period, :schedule => position.schedule)
      expect(period.memberships).to be_empty
    end

  end

end

