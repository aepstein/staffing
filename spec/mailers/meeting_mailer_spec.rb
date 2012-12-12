require "spec_helper"

describe MeetingMailer do
  describe "publish_notice" do
    let(:mail) { MeetingMailer.publish_notice }

    it "renders the headers" do
      mail.subject.should eq("Publish notice")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
