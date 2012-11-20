require "spec_helper"

describe MembershipMailer do
  include MailerSpecHelpers
  let(:authority) { create(:authority,
    join_message: "Welcome from the *authority*.",
    leave_message: "Farewell from the *authority*.") }
  let(:position) { create(:position,
    authority: authority,
    join_message: "Welcome to the *position*.",
    leave_message: "Farewell from the *position*.") }
  let(:membership) { create(:membership, position: position) }

  def should_have_common_enrollment_information
    create(:enrollment, position: membership.position, votes: 1,
      title: "member",
      committee: create(:committee,
        name: 'Important Committee',
        join_message: "Welcome to the *committee*.",
        leave_message: "Farewell from the *committee*."))
    both_parts_should_match /member of Important Committee with 1 vote/
  end

  def should_be_to_assignee
      mail.to.should eq([membership.user.email])
  end

  def should_be_from_effective_contact
    membership.position.authority.stub(:effective_contact_email).and_return("madison@example.com")
    membership.position.authority.stub(:effective_contact_name).and_return("James Madison")
    mail.from.should eq(["madison@example.com"])
  end

  describe "join" do
    let(:mail) { MembershipMailer.join_notice( membership ) }

    it "renders correct subject" do
      membership.stub(:description).and_return("Requested Committee")
      mail.subject.should eq "Your appointment to Requested Committee"
    end

    it "addresses to assignee of membership" do
      should_be_to_assignee
    end

    it "addresses from authority effective contact" do
      should_be_from_effective_contact
    end

    it "renders the standard body for a membership without enrollments" do
      both_parts_should_match /Dear #{membership.user.first_name},/
      both_parts_should_match <<EOS.gsub(/\s+/, " ").strip
        This notice is to inform you that you have been assigned a
        membership in #{membership.description}, for a term starting on
        #{membership.starts_at.to_formatted_s :long_ordinal} and ending on
        #{membership.ends_at.to_formatted_s :long_ordinal}.
EOS
      text_part_should_match /Welcome from the \*authority\*\./
      html_part_should_match /Welcome from the <em>authority<\/em>\./
      text_part_should_match /Welcome to the \*position\*\./
      html_part_should_match /Welcome to the <em>position<\/em>\./
      both_parts_should_not_match /Concurrent with your appointment to this position, you hold the following committee enrollments:/
    end

    it "renders the enrollment information for a membership with enrollments" do
      should_have_common_enrollment_information
      both_parts_should_match /Concurrent with your appointment to this position, you hold the following committee enrollments:/
      text_part_should_match /Welcome to the \*committee\*\./
      html_part_should_match /Welcome to the <em>committee<\/em>./
    end
  end

  describe "leave" do
  end

end

