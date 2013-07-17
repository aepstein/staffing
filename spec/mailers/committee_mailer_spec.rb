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
    
    before(:each) { vicechair; motion.propose! }
    
    it "renders all the components" do
      mail.subject.should eq "#{committee.name} must meet"
      mail.to.should include vicechair.email
      mail.from.should include committee.effective_contact_email
      both_parts_should_match "Dear #{vicechair.first_name},"
      both_parts_should_match "#{committee.name} has not met since the current session began on #{committee.schedule.periods.active.to_s :long_ordinal}."
      both_parts_should_match "The following motions have been proposed and are awaiting discussion and action:"
      text_part_should_match "#{motion.to_s :numbered} <"
      html_part_should_match "#{motion.to_s :numbered}"
    end
    
    it "renders mentions the most recent meeting that has occurred" do
      create(:meeting, committee: committee, period: motion.period,
        starts_at: Time.zone.now - 1.week)
      recent = create(:meeting, committee: committee, period: motion.period,
        starts_at: Time.zone.now - 1.day)
      mail
      both_parts_should_match "#{committee.name} has not met since #{recent.starts_at.to_date.to_s :long_ordinal}."
    end
  end
end
