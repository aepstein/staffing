require "spec_helper"

describe UserMailer do
  include MailerSpecHelpers
  let(:position) { create(:position, name: 'Important Position', renewable: true) }
  let (:membership) { create(:membership, position: position) }

  describe "renew" do
    let(:mail) { UserMailer.renew_notice( membership.user ) }

    it "has correct headers" do
      mail.subject.should eq "Your action is required to renew committee memberships"
      mail.to.should eq([membership.user.email])
      mail.from.should eq(["info@example.org"])
    end

    it "renders the correct messages in the body with unconfirmed membership" do
      both_parts_should_match /Dear #{membership.user.first_name},/
      both_parts_should_match <<EOS.gsub(/\s+/, " ").strip
Please take a few moments between now and
#{(Time.zone.today + 1.week).to_formatted_s :long_ordinal} to specify your renewal
preferences here:
EOS
      both_parts_should_match /you have the following unconfirmed renewal preferences/
      both_parts_should_not_match /Our records also indicate you have confirmed you are/
      html_part_should_match /<em>not<\/em> interested in renewing your membership in Important Position that ends on #{membership.period.ends_at.to_s :long_ordinal}/
      both_parts_should_match /Please take a few moments between now and #{( Time.zone.today + 1.week ).to_formatted_s :long_ordinal} to specify your renewal preferences/
      text_part_should_match /Please contact The Authority <info@example.org>/
      html_part_should_match /Please contact The Authority &lt;<a href="mailto:info@example.org">info@example.org<\/a>&gt;/
    end

    it "renders the correct messages in the body with confirmed membership" do
      membership.renewal_confirmed_at = membership.user.renewal_checkpoint
      membership.renew_until = ( membership.ends_at + 1.year )
      membership.save!
      both_parts_should_not_match /you have the following unconfirmed renewal preferences/
      both_parts_should_match /Our records also indicate you have confirmed you are/
      both_parts_should_match /interested in renewing your membership in Important Position that ends on #{membership.period.ends_at.to_s :long_ordinal} until #{membership.renew_until.to_formatted_s :long_ordinal}/
    end
  end
end

