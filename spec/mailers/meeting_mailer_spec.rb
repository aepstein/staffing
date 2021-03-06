require "spec_helper"

describe MeetingMailer, :type => :mailer do
  include MailerSpecHelpers
  let(:attachment) { create(:attachment, attachable: item) }
  let(:item) { create(:meeting_item) }
  let(:section) { item.meeting_section }
  let(:meeting) { section.meeting }
    
  before(:each) { attachment; item.reload; meeting.reload }
  
  describe "must_publish_notice" do
    let(:vicechair) { create(:membership, position: create(:enrollment,
      roles: %w( vicechair ),
      committee: meeting.committee).position ).user }
    let(:committee) { meeting.committee }
    let(:mail)  { MeetingMailer.must_publish_notice meeting }
    before(:each) { vicechair }
    
    it "renders all the components" do
      expect(mail.subject).to eq "Time to publish #{committee.name} meeting on #{meeting.starts_at.to_date.to_s :long_ordinal}"
      expect(mail.to).to include vicechair.email
      expect(mail.from).to include committee.effective_contact_email
      both_parts_should_match /Dear #{vicechair.first_name},/
      both_parts_should_match /#{committee.name} is scheduled to meet #{meeting.starts_at.to_s :long_ordinal} at #{meeting.location} in #{meeting.room}, but the meeting has not yet been published./
    end
  end

  describe "minutes_notice" do
    let(:clerk) { create(:membership, position: create(:enrollment,
      roles: %w( clerk ),
      committee: meeting.committee).position ).user }
    let(:committee) { meeting.committee }
    let(:mail) { MeetingMailer.minutes_notice( meeting ) }
    before(:each) { clerk }
    
    it "renders all the components" do
      expect(mail.subject).to eq "Minutes Needed for #{committee.name} meeting on #{meeting.starts_at.to_date.to_s :long_ordinal}"
      expect(mail.to).to include clerk.email
      expect(mail.from).to include  committee.effective_contact_email
      both_parts_should_match /Dear #{clerk.first_name},/
      both_parts_should_match /No minutes have been started for this meeting./
      both_parts_should_match /Minutes must be proposed for the #{committee.name} meeting which occurred on #{meeting.starts_at.to_date.to_s :long_ordinal}./
    end
  end

  describe "publish_notice" do
    let(:mail) { MeetingMailer.publish_notice( meeting,
      to: "info@example.org", from: "current@example.org" ) }

    it "renders all the components" do
      expect(mail.subject).to eq("#{meeting.committee.name} Meeting on #{meeting.starts_at.to_date.to_s :long_ordinal}")
      expect(mail.to).to include "info@example.org"
      expect(mail.from).to include "current@example.org"
      both_parts_should_match /AGENDA/
      both_parts_should_match /#{meeting.committee.name}/
      both_parts_should_match /#{meeting.starts_at.to_date.to_s :long_ordinal}/
      both_parts_should_match /#{meeting.to_s :time}/
      both_parts_should_match /#{meeting.location}/
      html_part_should_match /#{section.name}/
      text_part_should_match /I. #{section.name}/
      both_parts_should_not_match /No sections./
      html_part_should_match /#{item.name}/
      text_part_should_match /i. #{item.name}/
      both_parts_should_not_match /No items./
      html_part_should_match /#{attachment.description}/
      text_part_should_match /1. #{attachment.description}/
    end

    context "motion item" do
      before(:each) do
        VectorUploader.enable_processing = true
        create :brand
        VectorUploader.enable_processing = false
      end
      let(:motion) { item.motion }
      let(:attachment) { create :attachment, attachable: motion }
      let(:item) { create( :motion_meeting_item ) }

      it "should display motion and attachment for motion" do
        html_part_should_match /#{motion.to_s :numbered}/
        text_part_should_match /1. #{motion.to_s :numbered}/
        html_part_should_match /#{attachment.description}/
        text_part_should_match /2. #{attachment.description}/
      end

      context "motion item with comments" do
        before(:each) do
          motion.update_column :comment_until, Time.zone.now + 1.week
          create :motion_comment, motion: motion
          motion.reload
        end

        it "should display motion, comments, and attachment for motion" do
          html_part_should_match /#{motion.to_s :numbered}/
          text_part_should_match /1. #{motion.to_s :numbered}/
          html_part_should_match /Comments for #{motion.to_s :numbered}/
          text_part_should_match /2. Comments for #{motion.to_s :numbered}/
          html_part_should_match /#{attachment.description}/
          text_part_should_match /3. #{attachment.description}/
        end
      end
    end

    context "no attachment" do
      before(:each) { attachment.destroy }

      it "should display no attachments" do
        both_parts_should_not_match /\[1\]/
        both_parts_should_not_match /#{attachment.description}/
        both_parts_should_match /No attachments./
      end
    end

    context "no item" do
      before(:each) { item.destroy }

      it "should display no items" do
        both_parts_should_match /No items./
      end
    end

    context "no section" do
      before(:each) { section.destroy }

      it "should display no sections" do
        both_parts_should_match /No sections./
      end
    end
  end

end

