require "spec_helper"

describe MotionEventMailer do
  include MailerSpecHelpers
  let(:committee) { create(:committee, name: "Busy Committee") }
  let(:vicechair) { create( :membership, position: create(:enrollment,
    committee: committee, roles: %w( vicechair ) ).position ).user }
  let(:chair) { create( :membership, position: create(:enrollment,
    committee: committee, roles: %w( chair ) ).position ).user }
  let(:motion) { create(:sponsored_motion, name: 'Do something important', committee: committee) }
  let(:motion_event) { create( :motion_event, event: event, motion: motion ) }
  let(:mail) { described_class.event_notice( motion_event ) }

  context "propose" do
    let(:event) { "propose" }

    context "with chair and no vicechair" do
      before(:each) { chair }

      it "should have correct headers and content for chair" do
        mail.to.should_not include vicechair.email
        mail.to.should include chair.email
        both_parts_should_match /Dear #{chair.first_name},/
      end
    end

    context "with chair and vicechair" do
      before(:each) { chair; vicechair }

      it "should have correct content for all scenarios" do
        mail.subject.should eq "#{motion.to_s :full} proposed"
        mail.from.should include committee.effective_contact_email
        both_parts_should_match /on #{motion_event.occurrence.to_s :long_ordinal} for consideration by #{motion.committee}./
        both_parts_should_match /You may [\w\,\s]+ the motion here:/
        both_parts_should_match /#{committee.effective_contact_name}/
        both_parts_should_match /#{committee.effective_contact_email}/
      end

      it "should have correct headers and content for vicechair" do
        mail.to.should include vicechair.email
        mail.to.should_not include chair.email
        both_parts_should_match /Dear #{vicechair.first_name},/
      end

      context "sponsored" do
        let(:sponsor) { motion.users.first }

        it "should attribute proposed action to sponsors and copy them" do
          mail.cc.should include sponsor.email
          both_parts_should_match /#{sponsor.name} proposed #{motion.to_s :numbered} on/
        end
      end

      context "referred" do
        let(:motion) { create(:referred_motion, name: 'Do something important', committee: committee) }

        it "should attribute propose action to nobody" do
          mail
          both_parts_should_match /#{motion.to_s :numbered} was proposed on/
        end
      end
    end
  end
end

