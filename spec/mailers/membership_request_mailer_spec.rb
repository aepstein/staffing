require "spec_helper"

describe MembershipRequestMailer do
  include MailerSpecHelpers
  let(:position) { create( :position,
    name: 'Interesting Position',
    authority: create(:authority,
      contact_name: "James Madison",
      contact_email: "madison@example.com",
      reject_message: "Alternatives for the *authority*.") ) }
  let(:committee) { create :committee, name: 'Important Committee',
    reject_message: "Alternatives to the *committee*." }
  let(:enrollment) { create :enrollment, requestable: true, votes: 1,
    committee: committee, position: position, title: 'member' }
  let(:membership_request) { create(:membership_request, committee: enrollment.committee) }

  def should_be_to_requestor
      mail.to.should eq([membership_request.user.email])
  end

  describe "reject" do
    before(:each) do
      membership_request.rejected_by_authority = enrollment.position.authority
      membership_request.rejected_by_user = create(:user, admin: true)
      membership_request.rejection_comment = "You are the *weakest* link, goodbye."
      membership_request.reject!
    end
    let(:mail) { MembershipRequestMailer.reject_notice( membership_request ) }

    it "has correct headers" do
      mail.subject.should eq "Your request for appointment to #{membership_request.committee} was declined"
      should_be_to_requestor
      mail.from.should eq(["madison@example.com"])
    end

    it "renders the correct messages in the body" do
      both_parts_should_match /Dear #{membership_request.user.first_name},/
      both_parts_should_match <<EOS.gsub(/\s+/, " ").strip
This notice is to inform you that your request for appointment to
#{membership_request.committee} has been declined for the following reason\\(s\\):
EOS
      text_part_should_match /You are the \*weakest\* link, goodbye\./
      html_part_should_match /You are the <em>weakest<\/em> link, goodbye\./
      text_part_should_match /Alternatives to the \*committee\*\./
      html_part_should_match /Alternatives to the <em>committee<\/em>\./
      text_part_should_match /Alternatives for the \*authority\*\./
      html_part_should_match /Alternatives for the <em>authority<\/em>\./
    end
  end

  describe "close" do
    before(:each) do
      membership_request.close!
    end
    let(:mail) { MembershipRequestMailer.close_notice( membership_request ) }

    it "has correct headers" do
      mail.subject.should eq "Your request for appointment to #{membership_request.committee} was approved"
      should_be_to_requestor
      mail.from.should eq(["info@example.org"])
    end

    it "renders the correct messages in the body with no memberships" do
      both_parts_should_match /Dear #{membership_request.user.first_name},/
      both_parts_should_match <<EOS.gsub(/\s+/, " ").strip
This notice is to inform you that your request for appointment to
#{membership_request.committee} has been approved.
EOS
      both_parts_should_match /You have not been appointed to any positions as a result of this request./
    end

    it "renders membership information in the body with enrolled memberships" do
      membership = create(:membership,
        user: membership_request.user, position: enrollment.position)
      membership_request.memberships << membership
      both_parts_should_match /You have been appointed to the following position:/
      both_parts_should_match /member in Important Committee for a term beginning #{membership.starts_at.to_formatted_s :us_ordinal} and ending #{membership.ends_at.to_formatted_s :us_ordinal}/
    end

    it "renders membership information in the body with unenrolled memberships" do
      membership = create(:membership, user: membership_request.user,
        position: create(:position, name: 'Insignificant Position'))
      membership_request.memberships << membership
      both_parts_should_match /You have been appointed to the following position:/
      both_parts_should_match /Insignificant Position for a term beginning #{membership.starts_at.to_formatted_s :us_ordinal} and ending #{membership.ends_at.to_formatted_s :us_ordinal}/
    end
  end
end

