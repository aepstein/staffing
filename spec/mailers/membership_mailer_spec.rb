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
  let(:enrollment) { create(:enrollment, position: membership.position,
    votes: 1,
    title: "member",
    committee: create(:committee,
      name: 'Important Committee',
      join_message: "Welcome to the *committee*.",
      leave_message: "Farewell from the *committee*.")) }
  let(:membership) { create(:membership, position: position) }

  def should_be_to_assignee
      mail.to.should eq([membership.user.email])
  end

  def should_be_from_effective_contact
    membership.position.authority.stub(:effective_contact_email).and_return("madison@example.com")
    membership.position.authority.stub(:effective_contact_name).and_return("James Madison")
    mail.from.should eq(["madison@example.com"])
  end

  def should_copy_watchers
    watcher = create(:membership,
      position: create(:enrollment, committee: enrollment.committee,
        membership_notices: true ).position)
    old_watcher = create(:past_membership,
      position: create(:enrollment, committee: enrollment.committee,
        membership_notices: true ).position)
    non_watcher = create(:membership,
      position: create(:enrollment, committee: enrollment.committee,
        membership_notices: false ).position)
    mail.cc.should include watcher.user.email
    mail.cc.should_not include old_watcher
    mail.cc.should_not include non_watcher
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

    it "copies the watchers who overlap" do
      should_copy_watchers
    end

    it "addresses from authority effective contact" do
      should_be_from_effective_contact
    end

    it "renders the standard body for a membership without enrollments" do
      both_parts_should_match /Dear #{membership.user.first_name},/
      both_parts_should_match <<EOS.gsub(/\s+/, " ").strip
This notice is to inform you that you have been assigned a membership in
#{membership.description}, for a term starting on
#{membership.starts_at.to_formatted_s :long_ordinal} and ending on
#{membership.ends_at.to_formatted_s :long_ordinal}.
EOS
      text_part_should_match /Welcome from the \*authority\*\./
      html_part_should_match /Welcome from the <em>authority<\/em>\./
      text_part_should_match /Welcome to the \*position\*\./
      html_part_should_match /Welcome to the <em>position<\/em>\./
      both_parts_should_not_match /you hold the following committee enrollments:/
    end

    it "renders the enrollment information for a membership with enrollments" do
      enrollment
      both_parts_should_match /you hold the following committee enrollments:/
      both_parts_should_match /member of Important Committee with 1 vote/
      text_part_should_match /Welcome to the \*committee\*\./
      html_part_should_match /Welcome to the <em>committee<\/em>./
    end
  end

  describe "leave" do
    let(:mail) { MembershipMailer.leave_notice( membership ) }

    it "renders correct subject" do
      membership.stub(:description).and_return("Requested Committee")
      mail.subject.should eq "Expiration of your appointment to Requested Committee"
    end

    it "addresses to assignee of membership" do
      should_be_to_assignee
    end

    it "addresses from authority effective contact" do
      should_be_from_effective_contact
    end

    it "copies the watchers who overlap" do
      should_copy_watchers
    end

    it "renders the standard body for a membership without enrollments" do
      both_parts_should_match /Dear #{membership.user.first_name},/
      both_parts_should_match <<EOS.gsub(/\s+/, " ").strip
This notice is to inform you that your membership in #{membership.description},
which began on #{membership.starts_at.to_formatted_s :long_ordinal}, has expired
as of #{membership.ends_at.to_s :long_ordinal}.
EOS
      text_part_should_match /Farewell from the \*authority\*\./
      html_part_should_match /Farewell from the <em>authority<\/em>\./
      text_part_should_match /Farewell from the \*position\*\./
      html_part_should_match /Farewell from the <em>position<\/em>\./
      both_parts_should_not_match /your enrollment in the following committees has also expired:/
    end

    it "renders the enrollment information for a membership with enrollments" do
      enrollment
      both_parts_should_match /your enrollment in the following committees has also expired:/
      both_parts_should_match /member of Important Committee/
      text_part_should_match /Farewell from the \*committee\*\./
      html_part_should_match /Farewell from the <em>committee<\/em>./
    end
  end

  describe "decline" do
    let(:membership) { create(:membership, decline_comment: "Why you were *declined*.") }
    let(:mail) { MembershipMailer.decline_notice( membership ) }

    it "renders correct subject" do
      membership.stub(:description).and_return("Requested Committee")
      mail.subject.should eq "Renewal of your appointment to Requested Committee was declined"
    end

    it "addresses to assignee of membership" do
      should_be_to_assignee
    end

    it "copies the watchers who overlap" do
      should_copy_watchers
    end

    it "addresses from authority effective contact" do
      should_be_from_effective_contact
    end

    it "renders the standard body for a membership without enrollments" do
      both_parts_should_match /Dear #{membership.user.first_name},/
      both_parts_should_match <<EOS.gsub(/\s+/, " ").strip
This notice is to inform you that your membership in #{membership.description},
which began on #{membership.starts_at.to_formatted_s :long_ordinal}, will not be
renewed beyond the originally scheduled end date of
#{membership.ends_at.to_formatted_s :long_ordinal}.
EOS
      text_part_should_match /Why you were \*declined\*\./
      html_part_should_match /Why you were <em>declined<\/em>\./
    end
  end

end

