require "spec_helper"

shared_context "referred motion" do
  let(:motion) { create(:referred_motion, name: 'Do something important', committee: committee) }
  let(:referring_sponsor) { motion.referring_motion.users.first }
end

shared_context "with chair and no vicechair" do
  before(:each) { chair }

  def should_be_to_chair
    expect(mail.to).not_to include vicechair.email
    expect(mail.to).to include chair.email
    both_parts_should_match /Dear #{chair.first_name},/
  end

  def should_be_to_vicechair
    expect(mail.to).not_to include vicechair.email
    expect(mail.to).to include chair.email
    both_parts_should_match /Dear #{chair.first_name},/
  end

  def should_cc_vicechair
    expect(mail.cc).not_to include vicechair.email
    expect(mail.cc).to include chair.email
  end
end

shared_context "with chair and vicechair" do
  before(:each) { chair; vicechair }

  def should_be_to_chair
    expect(mail.to).not_to include vicechair.email
    expect(mail.to).to include chair.email
    both_parts_should_match /Dear #{chair.first_name},/
  end

  def should_be_to_vicechair
    expect(mail.to).to include vicechair.email
    expect(mail.to).not_to include chair.email
    both_parts_should_match /Dear #{vicechair.first_name},/
  end

  def should_cc_vicechair
    expect(mail.cc).to include vicechair.email
    expect(mail.cc).not_to include chair.email
  end
end

describe MotionEventMailer, :type => :mailer do
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
    expect(mail.from).to include committee.effective_contact_email
    both_parts_should_match /#{committee.effective_contact_name}/
    both_parts_should_match /#{committee.effective_contact_email}/
  end

  def should_cite_referral
    both_parts_should_match /The motion is a referral of #{motion.referring_motion.to_s :full}./
  end

  def should_be_to_sponsor
    expect(mail.to).to include sponsor.email
    both_parts_should_match /Dear #{sponsor.first_name},/
  end

  def should_cc_sponsor
    expect(mail.cc).to include sponsor.email
  end

  def should_be_to_referring_sponsor
    expect(mail.to).to include referring_sponsor.email
    both_parts_should_match /Dear #{referring_sponsor.first_name},/
  end

  def should_cc_referring_sponsor
    expect(mail.cc).to include referring_sponsor.email
  end

  context "propose" do
    let(:status) { "proposed" }
    let(:event) { "propose" }

    def should_have_propose
      should_be_to_vicechair
      should_have_layout
      expect(mail.subject).to eq "#{motion.to_s :full} proposed"
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
      expect(mail.subject).to eq "#{motion.to_s :full} restarted"
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
      expect(mail.subject).to eq "#{motion.to_s :full} withdrawn"
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
      expect(mail.subject).to eq "#{motion.to_s :full} rejected"
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
      expect(mail.subject).to eq "#{motion.to_s :full} amended"
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

  context "divide" do
    let(:status) { "divided" }
    let(:event) { "divide" }
    let(:dividing_motions) do
      (1..2).map do |i|
        create(:referred_motion, referring_motion: motion, committee: motion.committee, period: motion.period,
          name: "Dividing Motion #{i}")
      end
    end

    before(:each) { dividing_motions }

    def should_have_divide
      should_have_layout
      expect(mail.subject).to eq "#{motion.to_s :full} divided"
      both_parts_should_match /#{motion.committee} divided #{motion.to_s :numbered} on #{motion_event.occurrence.to_s :long_ordinal}./
      both_parts_should_match /No further actions are allowed or required regarding the motion./
      both_parts_should_match /#{dividing_motions[0].to_s :numbered}/
      both_parts_should_match /#{dividing_motions[1].to_s :numbered}/
      both_parts_should_not_match /#{dividing_motions[0].to_s :full}/
      both_parts_should_not_match /#{dividing_motions[1].to_s :full}/
    end

    context "with chair and vicechair" do
      include_context "with chair and vicechair"

      it "should have notify sponsor and cc vicechair" do
        should_have_divide
        should_be_to_vicechair
        should_cc_sponsor
      end
    end

    context "with chair and no vicechair" do
      include_context "with chair and no vicechair"

      it "should have notify sponsor and cc chair in lieu of vicechair" do
        should_have_divide
        should_be_to_vicechair
        should_cc_sponsor
      end
    end
  end

  context "merge" do
    let(:status) { "proposed" }
    let(:event) { "merge" }
    let(:motion_merger) do
      create(:motion_merger, merged_motion: motion)
    end

    before(:each) { motion_merger }

    def should_have_merge
      should_have_layout
      expect(mail.subject).to eq "#{motion.to_s :full} merged"
      both_parts_should_match /#{motion.committee} merged #{motion.to_s :numbered} into #{motion_merger.motion.to_s :numbered} on #{motion_event.occurrence.to_s :long_ordinal}./
      both_parts_should_match /No further actions are allowed or required regarding the motion./
    end

    context "with chair and vicechair" do
      include_context "with chair and vicechair"

      it "should have notify sponsor and cc vicechair" do
        should_have_merge
        should_be_to_vicechair
        should_cc_sponsor
      end
    end

    context "with chair and no vicechair" do
      include_context "with chair and no vicechair"

      it "should have notify sponsor and cc chair in lieu of vicechair" do
        should_have_merge
        should_be_to_vicechair
        should_cc_sponsor
      end
    end
  end

  context "adopt" do
    let(:status) { "adopted" }
    let(:event) { "adopt" }

    def should_have_adopt
      should_have_layout
      expect(mail.subject).to eq "#{motion.to_s :full} adopted"
      both_parts_should_match /#{motion.committee} adopted #{motion.to_s :numbered} on #{motion_event.occurrence.to_s :long_ordinal}./
      both_parts_should_match /You may [\w\,\s]+ the motion here:/
    end

    context "with chair and vicechair" do
      include_context "with chair and vicechair"

      it "should be to chair and cc sponsor" do
        should_have_adopt
        should_be_to_chair
        should_cc_sponsor
      end
    end
  end

  context "implement" do
    let(:status) { "implemented" }
    let(:event) { "implement" }

    def should_have_implement
      should_have_layout
      expect(mail.subject).to eq "#{motion.to_s :full} implemented"
      both_parts_should_match /#{motion.committee} implemented #{motion.to_s :numbered} on #{motion_event.occurrence.to_s :long_ordinal}./
      both_parts_should_match /No further actions are allowed or required regarding the motion./
    end

    context "with chair and vicechair" do
      include_context "with chair and vicechair"

      it "should be to chair and cc sponsor" do
        should_have_implement
        should_be_to_chair
        should_cc_sponsor
      end
    end
  end
end

