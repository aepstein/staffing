require "spec_helper"

describe MeetingMailer do
  include MailerSpecHelpers
  let(:motion) { create :motion }
  let(:committee) { motion.committee }
  
  describe "must_meet_notice" do
    let(:vicechair) { create(:membership, position: create(:enrollment,
      roles: %w( vicechair ),
      committee: committee).position ).user }
    let(:mail) { CommitteeMailer.must_meet_notice( committee ) }
    
    before(:each) { vicechair }
    
    it "renders all the components" do
      motion.propose!
      mail.subject.should eq "#{committee.name} must meet"
      mail.to.should include vicechair.email
      mail.from.should include committee.effective_contact_email
      both_parts_should_match "Dear #{vicechair.first_name},"
      both_parts_should_match "#{committee.name} has not met since the current session began on #{committee.schedule.periods.active.to_s :long_ordinal}."
      both_parts_should_match "The following motions have been proposed and are awaiting discussion and action:"
      text_part_should_match "#{motion.to_s :numbered} <"
      html_part_should_match "#{motion.to_s :numbered}"
    end
    
    it "does not mention the most recent meeting if it occurred in the past period" do
      past_period = committee.schedule.periods.create attributes_for( :past_period, schedule: nil )
      create(:meeting, committee: committee, period: past_period,
        starts_at: past_period.starts_at + 1.week)
      mail
      both_parts_should_match "#{committee.name} has not met since the current session began on #{committee.schedule.periods.active.to_s :long_ordinal}."
    end
    
    it "mentions the most recent meeting that has occurred" do
      create(:meeting, committee: committee, period: motion.period,
        starts_at: Time.zone.now - 1.week)
      recent = create(:meeting, committee: committee, period: motion.period,
        starts_at: Time.zone.now - 1.day)
      mail
      both_parts_should_match "#{committee.name} has not met since #{recent.starts_at.to_date.to_s :long_ordinal}."
    end
  end
end
