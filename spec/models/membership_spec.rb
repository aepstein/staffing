require 'spec_helper'

describe Membership do
  let(:membership) { build(:membership) }

  context 'validation' do

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

    it 'should not save with an unqualified user' do
      membership.position.qualifications << create(:qualification)
      membership.user = create(:user)
      membership.user.qualifications.should_not include membership.position.qualifications.first
      membership.save.should eql false
    end

    it 'should save with a qualified user' do
      membership.position.qualifications << create(:qualification)
      membership.user = create(:user)
      membership.position.qualifications.each { |q| membership.user.qualifications << q }
      membership.save.should eql true
    end

    it 'should not save with a duplicate user/position/period' do
      membership.save!
      membership.position.update_attribute :slots, 2
      duplicate = build( :membership, :user => membership.user,
        :period => membership.period, :position => membership.position )
      duplicate.save.should be_false
    end

    it 'should not save with an invalid renew_until value' do
      membership.renew_until = membership.ends_at
      membership.save.should be_false
    end

  end

  context 'vacancies' do

    it "should start with one assigned and one vacant membership" do
      membership.position.memberships.assigned.count.should eql 1
      membership.position.memberships.unassigned.count.should eql 1
    end

    it 'should detect concurrent membership memberships and prevent overstaffing' do
      second = create( :membership, :starts_at => membership.starts_at + 1.days,
        :ends_at => membership.ends_at - 1.days, :position => membership.position,
        :period => membership.period, :user => create(:user) )
      membership.reload
      over = build(:membership, :starts_at => membership.starts_at,
        :ends_at => membership.ends_at, :position => membership.position,
        :period => membership.period, :user => create(:user) )
      counts = over.concurrent_counts
      counts[0].should eql [membership.starts_at, 1]
      counts[1].should eql [second.starts_at, 2]
      counts[2].should eql [second.ends_at, 2]
      counts[3].should eql [membership.ends_at, 1]
      counts.size.should eql 4
      over.save.should eql false
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

    let(:membership) {
#      period = create(:period, schedule: create(:schedule) )
#      position = create(:position, schedule: period.schedule, slots: 2)
#      m = position.memberships.build
#      m.user = create(:user)
#      m.period = period
#      m.starts_at = period.starts_at
#      m.ends_at = period.ends_at
#      m.save!
#      m
      create :membership, position: create( :position, slots: 2 )
    }

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

  it 'should have an unrequested scope' do
    membership.save!
    requested = create(:membership, :request => create(:request) )
    Membership.unrequested.where { user_id != nil }.size.should eql 1
    Membership.unrequested.should include membership
  end

  context "claim request" do
    let( :committee ) { enrollment.committee }
    let( :position ) { enrollment.position }
    let( :enrollment ) { create :enrollment, requestable: true }
    let( :request ) { create :request, committee: committee }
    let( :membership ) { create :membership, position: position, user: request.user }
#    def committee
#      @committee ||= enrollment.committee
#    end

#    def position
#      @position ||= enrollment.position
#    end

#    def enrollment
#      @enrollment ||= create(:enrollment, requestable: true)
#    end

#    def request
#      @request ||= create(:request, committee: committee)
#    end

#    def membership
#      membership_local ||= create(:membership, position: position, user: request.user)
#    end

    before(:each) { request }

    it "should claim a matching request" do
      membership.request.should eql request
    end

    it "should not claim a request for an inactive committee" do
      committee.update_attribute :active, false
      membership.request.should be_nil
    end

    it "should not claim a request for a non-matching status position" do
      position.update_attribute :statuses_mask, 2
      ( position.statuses_mask & request.user.statuses_mask ).should eql 0
      membership.request.should be_nil
    end

    it "should not claim a request for an inactive position" do
      position.update_attribute :active, false
      membership.request.should be_nil
    end

    it "should not claim a request for non-requestable enrollment" do
      enrollment.update_attribute :requestable, false
      membership.request.should be_nil
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

  context 'renewable scopes' do

    it 'should have renewed and unrenewed scopes based on renewed_by_membership_id flag' do
      future = create(:future_period, :schedule => membership.position.schedule)
      renewed = create(:membership, :position => membership.position,
        :user => membership.user, :period => future)
      membership.update_attribute :renewed_by_membership_id, renewed.id
      Membership.renewed.length.should eql 1
      Membership.renewed.should include membership
      Membership.unrenewed.length.should eql 1
      Membership.unrenewed.should include renewed
    end

    it 'should have a renewable_to scope that returns memberships that a membership may renew' do
      renewable_to_scenario
      scope = Membership.renewable_to membership
      scope.should include @same_position
      scope.should include @same_committee
      scope.uniq.length.should eql 2
    end

    it 'should claim renewed_memberships which are in renewable_to scope and match user_id' do
      renewable_to_scenario
      @same_position.user.should_not eql @same_committee.user
      membership.user = @same_position.user
      membership.save!
      membership.renewed_memberships.length.should eql 1
      membership.renewed_memberships.should include @same_position
      membership.user = @same_committee.user
      membership.save!
      membership.renewed_memberships.length.should eql 1
      membership.renewed_memberships.should include @same_committee
    end

    it 'should have a renewable scope that fetches only if the associated position is renewable, end date is same as period end date, and the period is current or immediately before current' do
      position = create(:position, :slots => 2, :renewable => true)
      current = create(:membership, :position => position)
      current_truncated = create(:membership, :position => position, :period => current.period, :ends_at => current.period.ends_at - 1.day)
      current_period = current.period
      prior_period = create(:period, :schedule => current.period.schedule,
        :starts_at => ( current_period.starts_at - 1.year ),
        :ends_at => ( current_period.starts_at - 1.day ) )
      prior = create(:membership, :position => position,
        :period => prior_period )
      ancient_period = create(:period, :schedule => current.period.schedule,
        :starts_at => ( prior_period.starts_at - 1.year ),
        :ends_at => ( prior_period.starts_at - 1.day ) )
      ancient = create(:membership, :position => position,
        :period => ancient_period )
      future_period = create(:future_period, :schedule => ancient_period.schedule)
      future = create(:membership, :position => position, :period => future_period)
      scope = Membership.renewable
      scope.should include current
      scope.should include prior
      Membership.renewable.uniq.length.should eql 2
    end

    it 'should have an unrenewable scope that fetches only if the associated position is renewable' do
      membership.save!
      renewable = create(:membership, position: create(:renewable_position) )
      Membership.unrenewable.length.should eql 1
      Membership.unrenewable.should include membership
    end

    def renewable_to_scenario
      membership.save!
      membership.position.update_attribute :renewable, true
      past = create(:past_period, schedule: membership.position.schedule)
      @same_position = create(:membership, position: membership.position,
        period: past, renew_until: Time.zone.today + 1.week )
      @same_position.user.update_attribute :statuses_mask, 1
      membership.update_attribute :user, nil
      membership.position.update_attribute :statuses_mask, 1
      @same_committee = create(:past_membership, renew_until: Time.zone.today + 1.week )
      @same_committee.user.update_attribute :statuses_mask, 1
      different_mask = create(:past_membership, renew_until: Time.zone.today + 1.week )
      different_mask.user.update_attribute :statuses_mask, 2
      enrollment = create(:enrollment, position: membership.position)
      create(:enrollment, position: @same_committee.position, committee: enrollment.committee)
      create(:enrollment, position: different_mask.position, committee: enrollment.committee)
      different_position = create(:past_membership, renew_until: Time.zone.today + 1.week)
    end

    context 'renewable scope' do

      it "should include qualifying membership" do
        Membership.renewable.should include membership
      end

      it "should exclude non-renewable position membership" do
        membership.position.update_attribute :renewable, false
        Membership.renewable.should_not include membership
      end

      it "should exclude membership that does not end with period" do
        membership.ends_at -= 1.day
        membership.save!
        Membership.renewable.should_not include membership
      end

      it "should exclude a membership that is renewed" do
        current_membership = create( :membership, user: membership.user,
          period: current_period, position: membership.position )
        membership.update_attribute :renewed_by_membership_id, current_membership.id
        Membership.renewable.should_not include membership
      end

      it "should exclude a membership that is unassigned" do
        membership.update_attribute :user_id, nil
        Membership.renewable.should_not include membership
      end

    end

#    context 'renewable_to scope' do

#      let(:target) { current_period.memberships.
#        where { position_id.eq( membership.position_id ) }.first }

#      it "should include qualifying membership" do
#        Membership.renewable_to( target ).should include membership
#        membership.position.statuses_mask.should eql 0
#      end

#      it "should exclude if renew_until before today" do
#        membership.update_attribute( :renew_until, ( Time.zone.today - 1.day ) )
#        Membership.renewable_to( target ).should eql 0
#      end

#    end


    let( :membership ) { create( :past_membership,
      position: create( :renewable_position ),
      renew_until: Time.zone.today + 1.year ) }
    let( :current_period ) { create( :period,
      schedule: renewable_membership.position.schedule,
      starts_at: renewable_membership.ends_at + 1.day,
      ends_at: Time.zone.today + 1.year ) }

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

  it 'should have a watchers method that returns users with overlapping, concurrent enrollment with membership_notices flag set' do
    membership.save!
    position = membership.position
    past_period = create(:past_period, :schedule => position.schedule)
    membership.reload
    enrollment = create(:enrollment, :position => position)
    committee = enrollment.committee
    watcher_position = create(:position, :schedule => position.schedule)
    create(:enrollment, :position => watcher_position, :committee => committee, :membership_notices => true)
    watcher_membership = create(:membership, :position => watcher_position, :period => membership.period)
    past_watcher_membership = create(:membership, :position => watcher_position, :period => past_period)
    nonwatcher_position = create(:enrollment, :committee => committee).position
    nonwatcher_membership = create(:membership, :position => nonwatcher_position)
    membership.watchers.length.should eql 1
    membership.watchers.should include watcher_membership.user
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

end

