require "spec_helper"

shared_context "referred motion" do
  let(:motion) { create(:referred_motion, name: 'Do something important', committee: committee) }
  let(:referring_sponsor) { motion.referring_motion.users.first }
end

shared_context "with chair and no vicechair" do
  before(:each) { chair }

  def should_be_to_vicechair
    mail.to.should_not include vicechair.email
    mail.to.should include chair.email
    both_parts_should_match /Dear #{chair.first_name},/
  end

  def should_cc_vicechair
    mail.cc.should_not include vicechair.email
    mail.cc.should include chair.email
  end
end

shared_context "with chair and vicechair" do
  before(:each) { chair; vicechair }

  def should_be_to_vicechair
    mail.to.should include vicechair.email
    mail.to.should_not include chair.email
    both_parts_should_match /Dear #{vicechair.first_name},/
  end

  def should_cc_vicechair
    mail.cc.should include vicechair.email
    mail.cc.should_not include chair.email
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

  def should_have_layout
    mail.from.should include committee.effective_contact_email
    both_parts_should_match /#{committee.effective_contact_name}/
    both_parts_should_match /#{committee.effective_contact_email}/
  end

  def should_cite_referral
    both_parts_should_match /The motion is a referral of #{motion.referring_motion.to_s :full}./
  end

  def should_be_to_sponsor
    mail.to.should include sponsor.email
    both_parts_should_match /Dear #{sponsor.first_name},/
  end

  def should_cc_sponsor
    mail.cc.should include sponsor.email
  end

  def should_be_to_referring_sponsor
    mail.to.should include referring_sponsor.email
    both_parts_should_match /Dear #{referring_sponsor.first_name},/
  end

  def should_cc_referring_sponsor
    mail.cc.should include referring_sponsor.email
  end

  context "propose" do
    let(:status) { "proposed" }
    let(:event) { "propose" }

    def should_have_propose
      should_be_to_vicechair
      should_have_layout
      mail.subject.should eq "#{motion.to_s :full} proposed"
      both_parts_should_match /on #{motion_event.occurrence.to_s :long_ordinal} for consideration by #{motion.committee}./
      both_parts_should_match /You may [\w\,\s]+ the motion here:/
    end

    context "with chair and vicechair" do
      include_context "with chair and vicechair"

      it "should attribute proposed action to sponsors and copy them" do
        should_have_propose
        should_cc_sponsor
        both_parts_should_match /#{sponsor.name} proposed #{motion.to_s :numbered} on/
      end

      context "referred" do
        include_context "referred motion"

        it "should attribute propose action to nobody" do
          should_have_propose
          should_cc_referring_sponsor
          both_parts_should_match /#{motion.to_s :numbered} was proposed on/
        end
      end
    end

    context "with chair and no vicechair" do
      include_context "with chair and no vicechair"

      it "should address to chair as vicechair" do
        should_be_to_vicechair
      end
    end
  end

  context "restart" do
    let(:status) { "started" }
    let(:event) { "restart" }

    def should_have_restart
      should_have_layout
      mail.subject.should eq "#{motion.to_s :full} restarted"
      both_parts_should_match /#{motion.to_s :full} has been restarted and is now ready for you to edit further./
      both_parts_should_match /You may [\w\,\s]+ the motion here:/
    end

    context "with chair and vicechair" do
      include_context "with chair and vicechair"

      it "should have notify sponsor and cc vicechair" do
        should_have_restart
        should_be_to_sponsor
        should_cc_vicechair
      end
    end

    context "with chair and no vicechair" do
      include_context "with chair and no vicechair"

      it "should have notify sponsor and cc chair in lieu of vicechair" do
        should_have_restart
        should_be_to_sponsor
        should_cc_vicechair
      end
    end
  end

  context "withdraw" do
    let(:status) { "withdrawn" }
    let(:event) { "withdraw" }

    def should_have_withdraw
      should_have_layout
      mail.subject.should eq "#{motion.to_s :full} withdrawn"
      both_parts_should_match /You withdrew #{motion.to_s :numbered} from consideration by #{motion.committee} on #{motion_event.occurrence.to_s :long_ordinal}./
      both_parts_should_match /You may [\w\,\s]+ the motion here:/
    end

    context "with chair and vicechair" do
      include_context "with chair and vicechair"

      it "should have notify sponsor and cc vicechair" do
        should_have_withdraw
        should_be_to_sponsor
        should_cc_vicechair
      end
    end

    context "with chair and no vicechair" do
      include_context "with chair and no vicechair"

      it "should have notify sponsor and cc chair in lieu of vicechair" do
        should_have_withdraw
        should_be_to_sponsor
        should_cc_vicechair
      end
    end
  end

  context "reject" do
    let(:status) { "rejected" }
    let(:event) { "reject" }

    def should_have_reject
      should_have_layout
      mail.subject.should eq "#{motion.to_s :full} rejected"
      both_parts_should_match /#{motion.to_s :numbered} was rejected by #{motion.committee} on #{motion_event.occurrence.to_s :long_ordinal}./
      both_parts_should_match /No further actions are allowed or required regarding the motion./
    end

    context "with chair and vicechair" do
      include_context "with chair and vicechair"

      it "should have notify sponsor and cc vicechair" do
        should_have_reject
        should_be_to_sponsor
        should_cc_vicechair
      end
    end

    context "with chair and no vicechair" do
      include_context "with chair and no vicechair"

      it "should have notify sponsor and cc chair in lieu of vicechair" do
        should_have_reject
        should_be_to_sponsor
        should_cc_vicechair
      end
    end
  end

  context "amend" do
    let(:status) { "proposed" }
    let(:event) { "amend" }

    def should_have_amend
      should_have_layout
      mail.subject.should eq "#{motion.to_s :full} amended"
      both_parts_should_match /#{motion.committee} amended #{motion.to_s :numbered} on #{motion_event.occurrence.to_s :long_ordinal}./
      both_parts_should_match /You may [\w\,\s]+ the motion here:/
    end

    context "with chair and vicechair" do
      include_context "with chair and vicechair"

      it "should have notify sponsor and cc vicechair" do
        should_have_amend
        should_be_to_vicechair
        should_cc_sponsor
      end

      context "referred" do
        include_context "referred motion"

        it "should attribute amend action to nobody" do
          should_have_amend
          should_cc_referring_sponsor
        end
      end
    end

    context "with chair and no vicechair" do
      include_context "with chair and no vicechair"

      it "should have notify sponsor and cc chair in lieu of vicechair" do
        should_have_amend
        should_be_to_vicechair
        should_cc_sponsor
      end
    end
  end
end

