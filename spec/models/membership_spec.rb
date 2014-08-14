require 'spec_helper'

describe Membership, :type => :model do
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
      expect(membership.save).to be false
    end

    it 'should not save without a position' do
      membership.position = nil
      expect(membership.save).to be false
    end

    it 'should not save without a start date' do
      membership.starts_at = nil
      expect(membership.save).to be false
    end

    it 'should not save with a start date before the period start date' do
      membership.starts_at = (membership.period.starts_at - 1.day)
      expect(membership.save).to be false
    end

    it 'should not save without an end date' do
      membership.ends_at = nil
      expect(membership.save).to be false
    end

    it 'should not save with an end date that is after the period end date' do
      membership.ends_at = (membership.period.ends_at + 1.day)
      expect(membership.save).to be false
    end

    it 'should not save with an end date that is before the start date' do
      membership.ends_at = (membership.starts_at - 1.day)
      expect(membership.save).to be false
    end

    it 'should not save with a duplicate user/position/period' do
      membership.save!
      membership.position.update_attribute :slots, 2
      duplicate = build( :membership, user: membership.user,
        period: membership.period, position: membership.position )
      expect(duplicate.save).to be false
    end

    it 'should not save with an invalid renew_until value' do
      membership.renew_until = membership.ends_at
      expect(membership.save).to be false
    end

    it "should not save if it exceeds concurrent counts" do
      membership.save!
      conflict = build( :membership, position: membership.position,
        period: membership.period, starts_at: membership.starts_at + 1.day,
        ends_at: membership.ends_at - 1.day )
      expect(conflict.save).to be false
    end

    it "should save with a valid modifier" do
      membership.modifier = modifier
      membership.save!
    end

    it "should not save with a non-overlapping early modifier" do
      modifier_membership.update_column :ends_at, ( membership.starts_at - 1.day )
      membership.modifier = modifier
      expect(membership.save).to be false
    end

    it "should not save with a non-overlapping late modifier" do
      modifier_membership.update_column :starts_at, ( membership.ends_at + 1.day )
      modifier_membership.save!
      membership.modifier = modifier
      expect(membership.save).to be false
    end

  end
  
  context 'renewal preferences' do
    let(:membership) { create( :renewable_membership,
      renewal_confirmed_at: Time.zone.now,
      renewed_by_membership: create(:membership) ) }
      
    it "should reset renewal preferences on user changes" do
      membership.user = create(:user)
      membership.save!
      expect(membership.renew_until).to be_nil
      expect(membership.renewed_by_membership).to be_nil
      expect(membership.renewal_confirmed_at).to be_nil
    end
  end

  context 'description' do
    let(:membership) { create(:membership) }
    let(:committee) { create(:enrollment, requestable: true,
      position: membership.position).committee }
    let(:membership_request) { create(:membership_request,
      committee: create(:enrollment, requestable: true,
        position: membership.position).committee,
      user: membership.user,
      memberships: [ membership ] ) }

    it "should return requested committee if membership fulfills request" do
      membership_request
      expect(membership.description).to eq membership_request.committee.name
    end

    it "should return first requestable committee if requestable" do
      committee
      membership.reload
      expect(membership.description).to eq committee.name
    end

    it "should return position name if no requestable committee associated" do
      expect(membership.description).to eq membership.position.name
    end
  end

  context 'ends_within scope' do

    let(:membership) { create :membership, starts_at: Time.zone.today - 2.days,
      ends_at: Time.zone.today + 2.days }

    it "should include/exclude qualifying membership" do
      expect(Membership.ends_within(1.week)).to include membership
      expect(Membership.ends_within(1.day)).not_to include membership
    end

  end

  context 'temporal scopes' do

    let(:past) { create(:past_membership) }
    let(:current) { create(:current_membership) }
    let(:future) { create(:future_membership) }

    it "past should return only past" do
      expect(Membership.past).to include past
      expect(Membership.past).not_to include current, future
    end

    it "current should include only current" do
      expect(Membership.current).to include current
      expect(Membership.current).not_to include past, future
    end

    it "future should include only future" do
      expect(Membership.future).to include future
      expect(Membership.future).not_to include current, past
    end

    it "current_or_future should include current and future only" do
      expect(Membership.current_or_future).to include current, future
      expect(Membership.current_or_future).not_to include past
    end

    it "as_of today should include only current" do
      expect(Membership.as_of(Time.zone.today)).to include current
      expect(Membership.as_of(Time.zone.today)).not_to include past, future
    end

    it "overlap(current.ends_at, future.starts_at) should include current, future only" do
      expect(Membership.overlap(current.ends_at,future.starts_at)).to include current, future
      expect(Membership.overlap(current.ends_at,future.starts_at)).not_to include past
    end

    it "no_overlap(current.ends_at, future.starts_at) should include past only" do
      expect(Membership.no_overlap(current.ends_at,future.starts_at)).to include past
      expect(Membership.no_overlap(current.ends_at,future.starts_at)).not_to include current, future
    end
  end

  context "renew_until scope" do
    let(:membership) { create :membership, ends_at: Time.zone.today + 1.day,
      renew_until: Time.zone.today + 1.week }

    it "should include qualifying membership" do
      expect(Membership.renew_until( Time.zone.today )).to include membership
      expect(Membership.renew_until( Time.zone.today + 1.month )).not_to include membership
    end

    it "should be called with Time.zone.today by renew_active" do
      expect(Membership).to receive( :renew_until ).with( Time.zone.today )
      Membership.renew_active
    end
  end

  context 'assigned/unassigned scope' do

    let(:membership) { create :membership }

    it "should include/exclude qualifying membership" do
      expect(Membership.assigned).to include membership
      expect(Membership.unassigned).not_to include membership
    end

    it "should exclude/include membership without user" do
      membership.user = nil; membership.save!
      expect(Membership.assigned).not_to include membership
      expect(Membership.unassigned).to include membership
    end

  end

  context 'requested/unrequested scope' do

    let(:membership_request) { create :membership_request }
    let(:membership) { create :membership,
      position: membership_request.committee.positions.first,
      user: membership_request.user, membership_request: membership_request }

    it "should include/exclude qualifying membership" do
      expect(Membership.requested).to include membership
      expect(Membership.unrequested).not_to include membership
    end

    it "should exclude/include membership without membership_request" do
      membership.membership_request = nil; membership.save!
      expect(Membership.requested).not_to include membership
      expect(Membership.unrequested).to include membership
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
      expect(counts[0]).to eql [membership.starts_at, 1]
      expect(counts[1]).to eql [second.starts_at, 2]
      expect(counts[2]).to eql [second.ends_at, 2]
      expect(counts[3]).to eql [membership.ends_at, 1]
      expect(counts.size).to eql 4
    end
  end

  context 'minimum_slots behaviors' do

    let(:membership) {
      create :membership, position: create( :position, slots: 3, minimum_slots: 2 )
    }

    it "should start with one assigned and one vacant membership" do
      expect(membership.position.memberships.assigned.count).to eql 1
      expect(membership.position.memberships.unassigned.count).to eql 1
    end

    it 'should generate unassigned memberships when an membership membership is created' do
      expect(membership.position.memberships.count).to eql 2
      expect(membership.position.memberships).to include membership
      expect(membership.position.memberships.unassigned.count).to eql 1
      expect(membership.position.memberships.unassigned.first.id).to be > membership.id
    end

    it 'should regenerate unassigned memberships when an membership membership is altered' do
      unassigned = membership.position.memberships.unassigned.first
      membership.ends_at -= 1.days
      membership.save
      expect(membership.position.memberships.count).to eql 3
      expect(membership.position.memberships).to include membership
      expect(membership.position.memberships.unassigned.count).to eql 2
    end

    it 'should regenerate unassigned memberships when an membership membership is destroyed' do
      membership.destroy
      expect(membership.position.memberships.count).to eql 2
      expect(membership.position.memberships(true)).not_to include membership
      expect(membership.position.memberships.unassigned.count).to eql 2
      membership.position.memberships.unassigned.each { |m| expect(m.id).to be > membership.id }
    end

    it 'should not regenerate unassigned membership when an membership membership is destroyed if the position is inactive' do
      position = membership.position
      position.active = false
      position.save!
      membership.destroy
      position.memberships.reset
      expect(position.memberships.unassigned.length).to eql 0
    end

  end

  it 'should have a designees.populate method that creates a designee for each committee corresponding position is enrolled in' do
    membership.save!
    membership.position.update_attribute :designable, true
    enrollment_existing_designee = create(:enrollment, position: membership.position)
    enrollment_no_designee = create(:enrollment, position: membership.position)
    irrelevant_enrollment = create(:enrollment)
    expect(irrelevant_enrollment.position).not_to eql membership.position
    designee = create(:designee, membership: membership,
      committee: enrollment_existing_designee.committee)
    membership.designees.reload
    expect(membership.designees.size).to eql 1
    new_designees = membership.designees.populate
    expect(new_designees.size).to eql 1
    expect(new_designees.first.committee).to eql enrollment_no_designee.committee
  end
  
  context "decline renewal" do
    let(:membership) { create( :membership, renew_until: ( Time.zone.today + 2.years ) ) }
    let(:decline_attributes) { { decline_comment: "A decline message" } }
    let(:decliner) { create(:user, admin: true) }
    
    it "should decline renewal with correct arguments" do
      decline_membership
      membership.errors.each { |k,v| puts "#{k}: #{v}" }
      expect(decline_membership).to be true
      expect(membership.decline_comment).to eql decline_attributes[:decline_comment]
      expect(membership.declined_at).not_to be_nil
      expect(membership.declined_by_user).not_to be_nil
    end
    
    it "should not decline if already renewed" do
      next_period = create(:period, schedule: membership.period.schedule,
        starts_at: membership.period.ends_at + 1.day)
      new_membership = create(:membership, user: membership.user,
        position: membership.position, period: next_period )
      membership.renewed_by_membership = new_membership
      membership.save!
      expect(decline_membership).to be false
    end
    
    it "should clear decline records if user changes" do
      decline_membership
      membership.user = create(:user)
      membership.save!
      expect(membership.declined_at).to be_nil
      expect(membership.declined_by_user).to be_nil
      expect(membership.decline_comment).to be_nil
    end
    
    def decline_membership
      membership.decline_renewal( decline_attributes, user: decliner )
    end
  end

  context "claim membership_request" do
    let( :committee ) { enrollment.committee }
    let( :position ) { enrollment.position }
    let( :enrollment ) { create :enrollment, requestable: true }
    let( :membership_request ) { create :membership_request, committee: committee }
    let( :membership ) { create :membership, position: position, user: membership_request.user }

    before(:each) { membership_request }

    it "should claim a matching membership_request" do
      expect(membership_request.active?).to be true
      expect(membership.membership_request).to eql membership_request
      membership_request.reload
      expect(membership_request.closed?).to be true
    end

    it "should not claim a membership_request for an inactive committee" do
      committee.update_attribute :active, false
      expect(membership.membership_request).to be_nil
    end

    it "should not claim a membership_request for a non-matching status position" do
      position.update_attribute :statuses_mask, 2
      expect( position.statuses_mask & membership_request.user.statuses_mask ).to eql 0
      expect(membership.membership_request).to be_nil
    end

    it "should not claim a membership_request for an inactive position" do
      position.update_attribute :active, false
      expect(membership.membership_request).to be_nil
    end

    it "should not claim a membership_request for non-requestable enrollment" do
      enrollment.update_attribute :requestable, false
      expect(membership.membership_request).to be_nil
    end
    
    it "should unclaim a membership_request if membership no longer has user assigned" do
      membership.user = nil
      membership.save!
      expect(membership.membership_request).to be_nil
      expect(membership_request.active?).to be true
    end
    
    it "should unclaim a membership_request if membership is assigned to a different user" do
      membership.user = create(:user)
      membership.save!
      expect(membership.membership_request).to be_nil
      expect(membership_request.active?).to be true
    end
    
    context "non-qualified user" do
      let(:membership) { create( :membership, position: position ) }
      
      it "should not claim other user's membership_request" do
        membership_request
        expect(membership.membership_request).to be_nil
      end
    end

  end

  context 'notifiable' do

    it 'should have a notifiable scope that returns only memberships with users and notifiable position' do
      notifiable_scenario
      expect(Membership.notifiable.length).to eql 1
      expect(Membership.notifiable).to include @focus_membership
      expect(Membership.count).to eql 4
    end

    it 'should have a join_notice_pending scope that returns only memberships that are awaiting join notice' do
      notifiable_scenario
      expect(Membership.join_notice_pending.length).to eql 1
      expect(Membership.join_notice_pending).to include @focus_membership
      create( :notice, notifiable: @focus_membership, event: 'join' )
      expect(Membership.join_notice_pending.length).to eql 0
    end

    it 'should have a leave_notice_pending scope that returns only memberships that are awaiting leave notice' do
      notifiable_scenario Date.today - 1.year, Date.today - 1.day
      expect(Membership.leave_notice_pending.length).to eql 1
      expect(Membership.leave_notice_pending).to include @focus_membership
      create( :notice, notifiable: @focus_membership, event: 'leave' )
      expect(Membership.leave_notice_pending.length).to eql 0
    end

    it 'should clear membership notices if user is blank' do
      membership.save!
      create( :notice, notifiable: membership, event: 'join' )
      membership.user = nil
      membership.save!
      expect(membership.user_id).to be_nil
      membership.association(:notices).reset
      expect(membership.notices).to be_empty
    end

    it 'should have a send_join_notice! method' do
      membership.save!
      membership.send_join_notice!
      membership.reload
      expect(membership.notices.for_event('join')).not_to be_empty
    end

    it 'should have a send_leave_notice! method' do
      membership.save!
      membership.send_leave_notice!
      membership.reload
      expect(membership.notices.for_event('leave')).not_to be_empty
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
      expect(Membership.renewable).to include membership
      expect(Membership.unrenewable).not_to include membership
    end

    it "should exclude/include an inactive position" do
      membership.position.update_attribute :active, false
      expect(Membership.renewable).not_to include membership
      expect(Membership.unrenewable).to include membership
    end

    it "should exclude/include non-renewable position membership" do
      membership.position.update_attribute :renewable, false
      expect(Membership.renewable).not_to include membership
      expect(Membership.unrenewable).to include membership
    end

  end

  context "peers relation" do
    let(:committee) { create(:committee) }
    let(:membership) { create(:membership, position: create(:enrollment, committee: committee).position) }
    let(:peer) { create(:membership) }
    let(:peer_enrollment) { create(:enrollment, position: peer.position, committee: committee) }

    before(:each) { peer_enrollment }

    it "should include valid peer" do
      expect(membership.peers).to include peer
      expect(membership.peers).not_to include membership
    end

    it "should not include non-overlapping peer" do
      peer.update_column :starts_at, Time.zone.today
      membership.update_column :ends_at, Time.zone.today - 1.day
      expect(membership.peers).not_to include peer
    end

    it "should support with_roles scope" do
      expect(membership.peers.with_roles('chair')).to be_empty
      peer_enrollment.roles = %w( chair )
      peer_enrollment.save!
      expect(membership.peers.with_roles('chair')).to include peer
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
        expect(Membership.renewal_candidate).to include membership
      end

      it "should not include a non-renewable membership" do
        membership.position.update_attribute :renewable, false
        expect(Membership.unrenewable).to include membership
        expect(Membership.renewal_candidate).not_to include membership
      end

      it "should not include an unassigned membership" do
        membership.user = nil; membership.save!
        expect(Membership.unassigned).to include membership
        expect(Membership.renewal_candidate).not_to include membership
      end

      it "should not include a renewed membership" do
        membership.update_attribute :renewed_by_membership_id, future_membership.id
        expect(Membership.renewed).to include membership
        expect(Membership.renewal_candidate).not_to include membership
      end

      it "should not include an abridged membership" do
        membership.ends_at -= 1.month
        membership.save!
        expect(Membership.abridged).to include membership
        expect(Membership.renewal_candidate).not_to include membership
      end

      it "should not include a future membership" do
        expect(Membership.future).to include future_membership
        expect(Membership.recent).not_to include future_membership
        expect(Membership.renewal_candidate).not_to include future_membership
      end

      it "should include a past membership" do
        expect(Membership.past).to include past_membership
        expect(Membership.recent).to include past_membership
        expect(Membership.renewal_candidate).to include past_membership
      end

      it "should not include an ancient membership" do
        expect(Membership.past).to include ancient_membership
        expect(Membership.recent).not_to include ancient_membership
        expect(Membership.renewal_candidate).not_to include ancient_membership
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
        m.save!
        m.update_attribute( :renew_until, ( Time.zone.today + 1.year ) )
        m
      }

      def setup_same_committees
        expect(membership.position).not_to eql other_membership.position
        create :enrollment, position: membership.position, committee: committee
        create :enrollment, position: other_membership.position, committee: committee
      end

      def setup_past_membership
        past_membership
        membership.user = nil; membership.save!
      end

      it "should include a conforming membership" do
        expect(Membership.renewable_to(future_membership)).to include membership
      end

      it "should include a conforming membership (with same committees)" do
        setup_same_committees
        expect(Membership.renewable_to(future_membership)).to include membership, other_membership
      end

      it "should include a conforming membership (with matching status)" do
        other_membership.position.statuses = [ membership.user.status ]
        other_membership.position.save!
        setup_same_committees
        expect(Membership.renewable_to(future_membership)).to include membership, other_membership
      end

      it "should include conforming past membership of current membership" do
        setup_past_membership
        expect(Membership.renewable_to(membership)).to include past_membership
      end

      it "should not include a past membership that has a past renew_until" do
        setup_past_membership
        past_membership.update_attribute :renew_until, Time.zone.today - 1.day
        expect(Membership.renewable_to(membership)).not_to include past_membership
      end

      it "should not include a membership that has a non-overlapping renew_until" do
        membership.update_attribute :renew_until, future_membership.starts_at + 1.week
        future_membership.update_attribute :starts_at, membership.renew_until + 1.month
        expect(Membership.renewable_to(future_membership)).not_to include membership
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
        expect(Membership.renewable_to(future_membership)).not_to include other_membership
      end

      it "should not include a membership with different position (no committees)" do
        expect(Membership.renewable_to(future_membership)).not_to include other_membership
      end

      it "should not include a membership without committee of subject" do
        setup_same_committees
        create(:enrollment, position: membership.position)
        expect(Membership.renewable_to(future_membership)).not_to include other_membership
      end

      it "should not include a membership with committees not in subject" do
        setup_same_committees
        create(:enrollment, position: other_membership.position)
        expect(Membership.renewable_to(future_membership)).not_to include other_membership
      end

      it "should not include a membership belonging to a user of non-matching status" do
        setup_same_committees
        future_membership.position.statuses = %w( undergrad ); membership.save!
        other_membership.user.status = 'grad'; other_membership.user.save!
        expect(Membership.renewable_to(future_membership)).not_to include other_membership
      end

      it "should add a membership to renewed_memberships if renewable_to" do
        future_membership.user = membership.user
        future_membership.save!
        expect(future_membership.renewed_memberships).to include membership
        expect(Membership.renewable_to(future_membership)).not_to include membership
      end

    end

  end

end

