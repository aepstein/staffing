require "spec_helper"

shared_examples "to sponsor" do
  it "should address the sponsor as the recipient" do
    mail.to.should include sponsor.email
    both_parts_should_match /Dear #{sponsor.first_name},/
  end
end

shared_context "with chair and no vicechair" do
  before(:each) { chair }
end

shared_context "with chair and vicechair" do
  before(:each) { chair; vicechair }
end

shared_examples "from vicechair" do
  context "with chair and no vicechair" do
    include_context "with chair and no vicechair"
    it "should have correct headers and content for chair" do
      mail.cc.should_not include vicechair.email
      mail.cc.should include chair.email
    end
  end

  context "with chair and vicechair" do
    include_context "with chair and vicechair"
    it "should have correct headers and content for vicechair" do
      mail.cc.should include vicechair.email
      mail.cc.should_not include chair.email
    end
  end
end

shared_examples "to vicechair" do
  context "with chair and no vicechair" do
    include_context "with chair and no vicechair"
    it "should have correct headers and content for chair" do
      mail.to.should_not include vicechair.email
      mail.to.should include chair.email
      both_parts_should_match /Dear #{chair.first_name},/
    end
  end

  context "with chair and vicechair" do
    include_context "with chair and vicechair"
    it "should have correct headers and content for vicechair" do
      mail.to.should include vicechair.email
      mail.to.should_not include chair.email
      both_parts_should_match /Dear #{vicechair.first_name},/
    end
  end
end

shared_examples "layout" do
  it "should have common layout components" do
    mail.from.should include committee.effective_contact_email
    both_parts_should_match /#{committee.effective_contact_name}/
    both_parts_should_match /#{committee.effective_contact_email}/
  end
end

shared_examples "propose" do
  it "should have common elements of propose notice" do
    mail.subject.should eq "#{motion.to_s :full} proposed"
    both_parts_should_match /on #{motion_event.occurrence.to_s :long_ordinal} for consideration by #{motion.committee}./
    both_parts_should_match /You may [\w\,\s]+ the motion here:/
  end
end

shared_examples "restart" do
  it "should have common elements of restart notice" do
    mail.subject.should eq "#{motion.to_s :full} restarted"
    both_parts_should_match /#{motion.to_s :full} has been restarted and is now ready for you to edit further./
    both_parts_should_match /You may [\w\,\s]+ the motion here:/
  end
end

describe MotionEventMailer do
  include MailerSpecHelpers
  let(:committee) { create(:committee, name: "Busy Committee") }
  let(:sponsor) { motion.users.first }
  let(:vicechair) { create( :membership, position: create(:enrollment,
    committee: committee, roles: %w( vicechair ) ).position ).user }
  let(:chair) { create( :membership, position: create(:enrollment,
    committee: committee, roles: %w( chair ) ).position ).user }
  let(:motion) { create(:sponsored_motion, name: 'Do something important', committee: committee, status: status) }
  let(:motion_event) { create( :motion_event, event: event, motion: motion ) }
  let(:mail) { described_class.event_notice( motion_event ) }

  context "propose" do
    let(:status) { "proposed" }
    let(:event) { "propose" }

    include_examples "to vicechair"

    context "standard" do
      before(:each) { vicechair }

      include_examples "layout"
      include_examples "propose"

      it "should attribute proposed action to sponsors and copy them" do
        mail.cc.should include sponsor.email
        both_parts_should_match /#{sponsor.name} proposed #{motion.to_s :numbered} on/
      end

      context "referred" do
        let(:motion) { create(:referred_motion, name: 'Do something important', committee: committee) }

        include_examples "propose"

        it "should attribute propose action to nobody" do
          both_parts_should_match /#{motion.to_s :numbered} was proposed on/
        end
      end
    end
  end

  context "restart" do
    let(:status) { "started" }
    let(:event) { "restart" }

    include_examples "to sponsor"
    include_examples "from vicechair"

    context "standard" do
      before(:each) { vicechair }

      include_examples "layout"
      include_examples "restart"
    end
  end
end

