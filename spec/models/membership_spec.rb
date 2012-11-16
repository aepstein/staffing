require 'spec_helper'

describe Membership do
  let(:membership) { build(:membership) }

  context 'validation' do

    let(:modifier_membership) do
      authority = membership.position.authority
      committee = create(:committee)
      authority.committee = committee; authority.save!
      position = create(:enrollment, committee: committee ).position
      period = create(:period, schedule: position.schedule,
        starts_at: membership.starts_at - 1.week,
        ends_at: membership.ends_at + 1.week )
      create(:membership, position: position, period: period)
    end

    let(:modifier) { modifier_membership.user }

    it 'should create a new instance given valid attributes' do
      membership.save!
    end

    it 'should not save without a period' do
      membership.period = nil
      membership.save.should be_false
    end

    it 'should not save without a position' do
      membership.position = nil
      membership.save.should be_false
    end

    it 'should not save without a start date' do
      membership.starts_at = nil
      membership.save.should be_false
    end

    it 'should not save with a start date before the period start date' do
      membership.starts_at = (membership.period.starts_at - 1.day)
      membership.save.should be_false
    end

    it 'should not save without an end date' do
      membership.ends_at = nil
      membership.save.should be_false
    end

    it 'should not save with an end date that is after the period end date' do
      membership.ends_at = (membership.period.ends_at + 1.day)
      membership.save.should be_false
    end

    it 'should not save with an end date that is before the start date' do
      membership.ends_at = (membership.starts_at - 1.day)
      membership.save.should be_false
    end

    it 'should not save with a duplicate user/position/period' do
      membership.save!
      membership.position.update_attribute :slots, 2
      duplicate = build( :membership, user: membership.user,
        period: membership.period, position: membership.position )
      duplicate.save.should be_false
    end

    it 'should not save with an invalid renew_until value' do
      membership.renew_until = membership.ends_at
      membership.save.should be_false
    end

    it "should not save if it exceeds concurrent counts" do
      membership.save!
      conflict = build( :membership, position: membership.position,
        period: membership.period, starts_at: membership.starts_at + 1.day,
        ends_at: membership.ends_at - 1.day )
      conflict.save.should be_false
    end

    it "should save with a valid modifier" do
      membership.modifier = modifier
      membership.save!
    end

    it "should not save with a non-overlapping early modifier" do
      modifier_membership.update_column :ends_at, ( membership.starts_at - 1.day )
      membership.modifier = modifier
      membership.save.should be_false
    end

    it "should not save with a non-overlapping late modifier" do
      modifier_membership.update_column :starts_at, ( membership.ends_at + 1.day )
      modifier_membership.save!
      membership.modifier = modifier
      membership.save.should be_false
    end

  end

  context 'ends_within scope' do

    let(:membership) { create :membership, starts_at: Time.zone.today - 2.days,
      ends_at: Time.zone.today + 2.days }

    it "should include/exclude qualifying membership" do
      Membership.ends_within(1.week).should include membership
      Membership.ends_within(1.day).should_not include membership
    end

  end

  context 'temporal scopes' do

    let(:past) { create(:past_membership) }
    let(:current) { create(:current_membership) }
    let(:future) { create(:future_membership) }

    it "past should return only past" do
      Membership.past.should include past
      Membership.past.should_not include current, future
    end

    it "current should include only current" do
      Membership.current.should include current
      Membership.current.should_not include past, future
    end

    it "future should include only future" do
      Membership.future.should include future
      Membership.future.should_not include current, past
    end

    it "current_or_future should include current and future only" do
      Membership.current_or_future.should include current, future
      Membership.current_or_future.should_not include past
    end

    it "as_of today should include only current" do
      Membership.as_of(Time.zone.today).should include current
      Membership.as_of(Time.zone.today).should_not include past, future
    end

    it "overlap(current.ends_at, future.starts_at) should include current, future only" do
      Membership.overlap(current.ends_at,future.starts_at).should include current, future
      Membership.overlap(current.ends_at,future.starts_at).should_not include past
    end

    it "no_overlap(current.ends_at, future.starts_at) should include past only" do
      Membership.no_overlap(current.ends_at,future.starts_at).should include past
      Membership.no_overlap(current.ends_at,future.starts_at).should_not include current, future
    end
  end

  context "renew_until scope" do
    let(:membership) { create :membership, ends_at: Time.zone.today + 1.day,
      renew_until: Time.zone.today + 1.week }

    it "should include qualifying membership" do
      Membership.renew_until( Time.zone.today ).should include membership
      Membership.renew_until( Time.zone.today + 1.month ).should_not include membership
    end

    it "should be called with Time.zone.today by renew_active" do
      Membership.should_receive( :renew_until ).with( Time.zone.today )
      Membership.renew_active
    end
  end

  context 'assigned/unassigned scope' do

    let(:membership) { create :membership }

    it "should include/exclude qualifying membership" do
      Membership.assigned.should include membership
      Membership.unassigned.should_not include membership
    end

    it "should exclude/include membership without user" do
      membership.user = nil; membership.save!
      Membership.assigned.should_not include membership
      Membership.unassigned.should include membership
    end

  end

  context 'requested/unrequested scope' do

    let(:membership_request) { create :membership_request }
    let(:membership) { create :membership,
      position: membership_request.committee.positions.first,
      user: membership_request.user, membership_request: membership_request }

    it "should include/exclude qualifying membership" do
      Membership.requested.should include membership
      Membership.unrequested.should_not include membership
    end

    it "should exclude/include membership without membership_request" do
      membership.membership_request = nil; membership.save!
      Membership.requested.should_not include membership
      Membership.unrequested.should include membership
    end

  end

  context 'concurrent_counts' do
    let(:membership) {
      create :membership, position: create( :position, slots: 3 )
    }

    it 'should detect concurrent membership memberships and prevent overstaffing' do
      second = create( :membership, starts_at: membership.starts_at + 1.days,
        ends_at: membership.ends_at - 1.days, position: membership.position,
        period: membership.period, user: create(:user) )
      membership.reload
      over = build(:membership, starts_at: membership.starts_at,
        ends_at: membership.ends_at, position: membership.position,
        period: membership.period, user: create(:user) )
      counts = over.concurrent_counts
      counts[0].should eql [membership.starts_at, 1]
      counts[1].should eql [second.starts_at, 2]
      counts[2].should eql [second.ends_at, 2]
      counts[3].should eql [membership.ends_at, 1]
      counts.size.should eql 4
    end
  end

  context 'minimum_slots behaviors' do

    let(:membership) {
      create :membership, position: create( :position, slots: 3, minimum_slots: 2 )
    }

    it "should start with one assigned and one vacant membership" do
      membership.position.memberships.assigned.count.should eql 1
      membership.position.memberships.unassigned.count.should eql 1
    end

    it 'should generate unassigned memberships when an membership membership is created' do
      membership.position.memberships.count.should eql 2
      membership.position.memberships.should include membership
      membership.position.memberships.unassigned.count.should eql 1
      membership.position.memberships.unassigned.first.id.should > membership.id
    end

    it 'should regenerate unassigned memberships when an membership membership is altered' do
      unassigned = membership.position.memberships.unassigned.first
      membership.ends_at -= 1.days
      membership.save
      membership.position.memberships.count.should eql 3
      membership.position.memberships.should include membership
      membership.position.memberships.unassigned.count.should eql 2
    end

    it 'should regenerate unassigned memberships when an membership membership is destroyed' do
      membership.destroy
      membership.position.memberships.count.should eql 2
      membership.position.memberships(true).should_not include membership
      membership.position.memberships.unassigned.count.should eql 2
      membership.position.memberships.unassigned.each { |m| m.id.should > membership.id }
    end

    it 'should not regenerate unassigned membership when an membership membership is destroyed if the position is inactive' do
      position = membership.position
      position.active = false
      position.save!
      membership.destroy
      position.memberships.reset
      position.memberships.unassigned.length.should eql 0
    end

  end

  it 'should have a designees.populate method that creates a designee for each committee corresponding position is enrolled in' do
    membership.save!
    membership.position.update_attribute :designable, true
    enrollment_existing_designee = create(:enrollment, position: membership.position)
    enrollment_no_designee = create(:enrollment, position: membership.position)
    irrelevant_enrollment = create(:enrollment)
    irrelevant_enrollment.position.should_not eql membership.position
    designee = create(:designee, membership: membership,
      committee: enrollment_existing_designee.committee)
    membership.designees.reload
    membership.designees.size.should eql 1
    new_designees = membership.designees.populate
    new_designees.size.should eql 1
    new_designees.first.committee.should eql enrollment_no_designee.committee
  end

  context "claim membership_request" do
    let( :committee ) { enrollment.committee }
    let( :position ) { enrollment.position }
    let( :enrollment ) { create :enrollment, requestable: true }
    let( :membership_request ) { create :membership_request, committee: committee }
    let( :membership ) { create :membership, position: position, user: membership_request.user }

    before(:each) { membership_request }

    it "should claim a matching membership_request" do
      membership.membership_request.should eql membership_request
    end

    it "should not claim a membership_request for an inactive committee" do
      committee.update_attribute :active, false
      membership.membership_request.should be_nil
    end

    it "should not claim a membership_request for a non-matching status position" do
      position.update_attribute :statuses_mask, 2
      ( position.statuses_mask & membership_request.user.statuses_mask ).should eql 0
      membership.membership_request.should be_nil
    end

    it "should not claim a membership_request for an inactive position" do
      position.update_attribute :active, false
      membership.membership_request.should be_nil
    end

    it "should not claim a membership_request for non-requestable enrollment" do
      enrollment.update_attribute :requestable, false
      membership.membership_request.should be_nil
    end

  end

  context 'notifiable' do

    it 'should have a notifiable scope that returns only memberships with users and notifiable position' do
      notifiable_scenario
      Membership.notifiable.length.should eql 1
      Membership.notifiable.should include @focus_membership
      Membership.count.should eql 4
    end

    it 'should have a join_notice_pending scope that returns only memberships that are awaiting join notice' do
      notifiable_scenario
      Membership.join_notice_pending.length.should eql 1
      Membership.join_notice_pending.should include @focus_membership
      @focus_membership.join_notice_at = Time.zone.now
      @focus_membership.save!
      Membership.join_notice_pending.length.should eql 0
    end

    it 'should have a leave_notice_pending scope that returns only memberships that are awaiting leave notice' do
      notifiable_scenario Date.today - 1.year, Date.today - 1.day
      Membership.leave_notice_pending.length.should eql 1
      Membership.leave_notice_pending.should include @focus_membership
      @focus_membership.leave_notice_at = Time.zone.now
      @focus_membership.save!
      Membership.leave_notice_pending.length.should eql 0
    end

    it 'should clear membership notices if user is blank' do
      membership.save!
      membership.update_attribute :join_notice_at, Time.zone.now
      membership.update_attribute :leave_notice_at, Time.zone.now
      membership.user = nil
      membership.save!
      membership.user_id.should be_nil
      membership.join_notice_at.should be_nil
      membership.leave_notice_at.should be_nil
    end

    it 'should have a send_join_notice! method' do
      membership.save!
      membership.send_join_notice!
      membership.reload
      membership.join_notice_at.should_not be_nil
    end

    it 'should have a send_leave_notice! method' do
      membership.save!
      membership.send_leave_notice!
      membership.reload
      membership.leave_notice_at.should_not be_nil
    end

    def notifiable_scenario(starts_at = nil, ends_at = nil)
      starts_at ||= Date.today - 1.year
      ends_at ||= starts_at + 2.years
      schedule = create(:period, :starts_at => starts_at, :ends_at => ends_at).schedule
      focus_position = create(:position, :notifiable => true, :slots => 2, :schedule => schedule)
      other_position = create(:position, :slots => 2, :schedule => schedule)
      @focus_membership = create(:membership, :position => focus_position, :user => create(:user) )
      create(:membership, :position => other_position, :user => create(:user) )
    end

  end

  context 'renewable/unrenewable scope' do

    let(:membership) { create :membership, position: create( :position,
      renewable: true ) }

    it "should include/exclude qualifying membership" do
      Membership.renewable.should include membership
      Membership.unrenewable.should_not include membership
    end

    it "should exclude/include an inactive position" do
      membership.position.update_attribute :active, false
      Membership.renewable.should_not include membership
      Membership.unrenewable.should include membership
    end

    it "should exclude/include non-renewable position membership" do
      membership.position.update_attribute :renewable, false
      Membership.renewable.should_not include membership
      Membership.unrenewable.should include membership
    end

  end

  context "watchers" do
    let(:committee) { create :committee }
    let(:membership) { create :membership,
      position: create( :enrollment, committee: committee ).position }
    let(:watcher_membership) { create( :membership, position: create( :enrollment,
      committee: committee, membership_notices: true ).position ) }
    let(:watcher) { watcher_membership.user }

    it "should return qualifying watchers" do
      membership.watchers.should include watcher
    end

    it "should not include non-watcher peers" do
      watcher_membership.position.enrollments.first.update_attribute :membership_notices, false
      membership.watchers.should_not include watcher
    end

    it "should not include watchers from other committees" do
      watcher_membership.destroy
      watcher = create( :membership, position: create( :enrollment,
        membership_notices: true ).position ).user
      membership.watchers.should be_empty
    end

    it "should not include temporally non-overlapping watchers" do
      membership.ends_at -= 1.month
      membership.save!
      watcher_membership.starts_at = membership.ends_at + 1.day
      watcher_membership.save!
      membership.watchers.should_not include watcher
    end
  end

  context 'renewal/renewable' do

    let( :membership ) { create :membership,
      position: create( :renewable_position ) }
    let( :past_period ) { create :period, schedule: membership.position.schedule,
      starts_at: membership.starts_at - 1.years,
      ends_at: membership.starts_at - 1.day
    }
    let( :ancient_period ) { create :period, schedule: membership.position.schedule,
      starts_at: past_period.starts_at - 1.year,
      ends_at: past_period.starts_at - 1.day }
    let( :future_period ) { create :period,
      schedule: membership.position.schedule,
      starts_at: membership.ends_at + 1.day }

    context 'renewable scope' do

      let( :future_membership ) { create :membership, user: membership.user,
        position: membership.position, period: future_period }
      let( :ancient_membership ) { create( :membership, user: membership.user,
          position: membership.position, period: ancient_period ) }
      let( :past_membership ) { create( :membership, user: membership.user,
        position: membership.position, period: past_period ) }

      it "should include a conforming membership" do
        Membership.renewal_candidate.should include membership
      end

      it "should not include a non-renewable membership" do
        membership.position.update_attribute :renewable, false
        Membership.unrenewable.should include membership
        Membership.renewal_candidate.should_not include membership
      end

      it "should not include an unassigned membership" do
        membership.user = nil; membership.save!
        Membership.unassigned.should include membership
        Membership.renewal_candidate.should_not include membership
      end

      it "should not include a renewed membership" do
        membership.update_attribute :renewed_by_membership_id, future_membership.id
        Membership.renewed.should include membership
        Membership.renewal_candidate.should_not include membership
      end

      it "should not include an abridged membership" do
        membership.ends_at -= 1.month
        membership.save!
        Membership.abridged.should include membership
        Membership.renewal_candidate.should_not include membership
      end

      it "should not include a future membership" do
        Membership.future.should include future_membership
        Membership.recent.should_not include future_membership
        Membership.renewal_candidate.should_not include future_membership
      end

      it "should include a past membership" do
        Membership.past.should include past_membership
        Membership.recent.should include past_membership
        Membership.renewal_candidate.should include past_membership
      end

      it "should not include an ancient membership" do
        Membership.past.should include ancient_membership
        Membership.recent.should_not include ancient_membership
        Membership.renewal_candidate.should_not include ancient_membership
      end

    end

    context 'renewable_to scope' do
      let( :committee ) { create :committee }
      let( :period ) { create :period, starts_at: Time.zone.today - 1.year,
        ends_at: Time.zone.today + 1.month }
      let( :membership ) { create :membership, position: create( :renewable_position,
        schedule: period.schedule ), period: period,
        renew_until: period.ends_at + 1.year }
      let( :other_membership ) { create :membership, position: create( :renewable_position,
        schedule: period.schedule ), period: period,
        renew_until: period.ends_at + 1.year }
      let( :future_membership ) { future_period.memberships.
        where { |m| m.position_id.eq( membership.position_id ) }.first }
      let( :past_membership ) {
        m = past_period.memberships.
        where { |m| m.position_id.eq( membership.position_id ) }.first
        m.user = membership.user
        m.renew_until = Time.zone.today + 1.year
        m.save!
        m
      }

      def setup_same_committees
        membership.position.should_not eql other_membership.position
        create :enrollment, position: membership.position, committee: committee
        create :enrollment, position: other_membership.position, committee: committee
      end

      def setup_past_membership
        past_membership
        membership.user = nil; membership.save!
      end

      it "should include a conforming membership" do
        Membership.renewable_to(future_membership).should include membership
      end

      it "should include a conforming membership (with same committees)" do
        setup_same_committees
        Membership.renewable_to(future_membership).should include membership, other_membership
      end

      it "should include a conforming membership (with matching status)" do
        other_membership.position.statuses = [ membership.user.status ]
        other_membership.position.save!
        setup_same_committees
        Membership.renewable_to(future_membership).should include membership, other_membership
      end

      it "should include conforming past membership of current membership" do
        setup_past_membership
        Membership.renewable_to(membership).should include past_membership
      end

      it "should not include a past membership that has a past renew_until" do
        setup_past_membership
        past_membership.update_attribute :renew_until, Time.zone.today - 1.day
        Membership.renewable_to(membership).should_not include past_membership
      end

      it "should not include a membership that has a non-overlapping renew_until" do
        membership.update_attribute :renew_until, future_membership.starts_at + 1.week
        future_membership.update_attribute :starts_at, membership.renew_until + 1.month
        Membership.renewable_to(future_membership).should_not include membership
      end

      it "should not include a membership that overlaps" do
        setup_same_committees
        other_membership.position.schedule = create(:schedule)
        other_membership.position.schedule.periods << build(:period,
          starts_at: membership.starts_at + 1.week, ends_at: membership.ends_at + 1.week)
        other_membership.starts_at += 1.week
        other_membership.ends_at += 1.week
        other_membership.period = other_membership.position.schedule.periods.first
        other_membership.save!
        Membership.renewable_to(future_membership).should_not include other_membership
      end

      it "should not include a membership with different position (no committees)" do
        Membership.renewable_to(future_membership).should_not include other_membership
      end

      it "should not include a membership without committee of subject" do
        setup_same_committees
        create(:enrollment, position: membership.position)
        Membership.renewable_to(future_membership).should_not include other_membership
      end

      it "should not include a membership with committees not in subject" do
        setup_same_committees
        create(:enrollment, position: other_membership.position)
        Membership.renewable_to(future_membership).should_not include other_membership
      end

      it "should not include a membership belonging to a user of non-matching status" do
        setup_same_committees
        future_membership.position.statuses = %w( undergrad ); membership.save!
        other_membership.user.status = 'grad'; other_membership.user.save!
        Membership.renewable_to(future_membership).should_not include other_membership
      end

      it "should add a membership to renewed_memberships if renewable_to" do
        future_membership.user = membership.user
        future_membership.save!
        future_membership.renewed_memberships.should include membership
        Membership.renewable_to(future_membership).should_not include membership
      end

    end

  end

end

