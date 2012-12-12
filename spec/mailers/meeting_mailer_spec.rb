require "spec_helper"

describe MeetingMailer do
  include MailerSpecHelpers
  let(:attachment) { create(:attachment, attachable: item) }
  let(:item) { create(:meeting_item) }
  let(:section) { item.meeting_section }
  let(:meeting) { section.meeting }
  let(:mail) { MeetingMailer.publish_notice( meeting,
    to: "info@example.org", from: "current@example.org" ) }

  describe "publish_notice" do
    before(:each) { attachment; item.reload; meeting.reload }

    it "renders all the components" do
      mail.subject.should eq("#{meeting.committee.name} Meeting on #{meeting.starts_at.to_date.to_s :long_ordinal}")
      mail.to.should include "info@example.org"
      mail.from.should include "current@example.org"
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

