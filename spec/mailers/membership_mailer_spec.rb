require "spec_helper"

describe MembershipMailer, :type => :mailer do
  include MailerSpecHelpers
  let(:authority) { create(:authority,
    appoint_message: "Greetings from the *authority*.",
    join_message: "Welcome from the *authority*.",
    leave_message: "Farewell from the *authority*.") }
  let(:position) { create(:position,
    authority: authority,
    appoint_message: "Congratulations on the *position*.",
    join_message: "Welcome to the *position*.",
    leave_message: "Farewell from the *position*.") }
  let(:enrollment) { create(:enrollment, position: membership.position,
    votes: 1,
    title: "member",
    committee: create(:committee,
      name: 'Important Committee',
      appoint_message: "Congratulations on the *committee*.",
      join_message: "Welcome to the *committee*.",
      leave_message: "Farewell from the *committee*.")) }
  let(:membership) { create(:membership, position: position) }

  def should_be_to_assignee
      expect(mail.to).to eq([membership.user.email])
  end

  def should_be_from_effective_contact
    allow(membership.position.authority).to receive(:effective_contact_email).and_return("madison@example.com")
    allow(membership.position.authority).to receive(:effective_contact_name).and_return("James Madison")
    expect(mail.from).to eq(["madison@example.com"])
  end

  def should_copy_monitors
    monitor = create(:membership)
    create(:enrollment, committee: enrollment.committee, roles: %w( monitor ),
      position: monitor.position )
    pro_monitor = create(:membership, starts_at: ( Time.zone.today + 1.day ) )
    create(:enrollment, committee: enrollment.committee, roles: %w( monitor ),
      position: pro_monitor.position)
    no_overlap_monitor = create(:future_membership)
    create(:enrollment, committee: enrollment.committee,
      position: no_overlap_monitor.position, roles: %w( monitor ) )
    old_monitor = create(:membership, ends_at: ( Time.zone.today - 1.day ))
    create(:enrollment, committee: enrollment.committee, roles: %w( monitor ),
      position: old_monitor.position )
    non_monitor = create(:membership)
    create(:enrollment, committee: enrollment.committee, roles: %w( vicechair ),
      position: non_monitor.position )
    expect(mail.cc).to include monitor.user.email
    expect(mail.cc).to include pro_monitor.user.email
    expect(mail.cc).not_to include old_monitor.user.email
    expect(mail.cc).not_to include no_overlap_monitor.user.email
    expect(mail.cc).not_to include non_monitor.user.email
  end

  describe "appoint" do
    let(:mail) { MembershipMailer.appoint_notice( membership ) }

    it "renders correct subject" do
      allow(membership).to receive(:description).and_return("Requested Committee")
      expect(mail.subject).to eq "Your upcoming appointment to Requested Committee"
    end

    it "addresses to assignee of membership" do
      should_be_to_assignee
    end

    it "copies the monitors who overlap" do
      should_copy_monitors
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
      text_part_should_match /Greetings from the \*authority\*\./
      html_part_should_match /Greetings from the <em>authority<\/em>\./
      text_part_should_match /Congratulations on the \*position\*\./
      html_part_should_match /Congratulations on the <em>position<\/em>\./
      both_parts_should_not_match /you will hold the following committee enrollments:/
    end

    it "renders the enrollment information for a membership with enrollments" do
      enrollment
      both_parts_should_match /you will hold the following committee enrollments:/
      both_parts_should_match /member of Important Committee with 1 vote/
      text_part_should_match /Congratulations on the \*committee\*\./
      html_part_should_match /Congratulations on the <em>committee<\/em>./
    end
  end

  describe "join" do
    let(:mail) { MembershipMailer.join_notice( membership ) }

    it "renders correct subject" do
      allow(membership).to receive(:description).and_return("Requested Committee")
      expect(mail.subject).to eq "Your appointment to Requested Committee"
    end

    it "addresses to assignee of membership" do
      should_be_to_assignee
    end

    it "copies the monitors who overlap" do
      should_copy_monitors
    end

    it "addresses from authority effective contact" do
      should_be_from_effective_contact
    end

    it "renders the standard body for a membership without enrollments" do
      both_parts_should_match /Dear #{membership.user.first_name},/
      both_parts_should_match <<EOS.gsub(/\s+/, " ").strip
This notice is to inform you that you have begun a membership in
#{membership.description}, for a term starting on
#{membership.starts_at.to_formatted_s :long_ordinal} and ending on
#{membership.ends_at.to_formatted_s :long_ordinal}.
EOS
      both_parts_should_match <<EOS.gsub(/\s+/, " ").strip
You will not be asked to renew in the future.
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
    
    context "renewable membership" do
      let(:position) { create(:position, renewable: true) }
      
      it "should indicate renewal will be requested at a later date" do
        both_parts_should_match <<EOS.gsub(/\s+/, " ").strip
You will be offered the opportunity to renew in the future.
EOS
      end
    end
  end

  describe "leave" do
    let(:mail) { MembershipMailer.leave_notice( membership ) }

    it "renders correct subject" do
      allow(membership).to receive(:description).and_return("Requested Committee")
      expect(mail.subject).to eq "Expiration of your appointment to Requested Committee"
    end

    it "addresses to assignee of membership" do
      should_be_to_assignee
    end

    it "addresses from authority effective contact" do
      should_be_from_effective_contact
    end

    it "copies the monitors who overlap" do
      should_copy_monitors
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
      allow(membership).to receive(:description).and_return("Requested Committee")
      expect(mail.subject).to eq "Renewal of your appointment to Requested Committee was declined"
    end

    it "addresses to assignee of membership" do
      should_be_to_assignee
    end

    it "copies the monitors who overlap" do
      should_copy_monitors
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

