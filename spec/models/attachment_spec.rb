require 'spec_helper'

describe Attachment, :type => :model do

  let(:attachment) { build :attachment }

  it "should save with valid attributes" do
    attachment.save!
  end

  it "should not save without an attachable" do
    attachment.attachable = nil
    expect(attachment.save).to be false
  end

  it "should not save without a description" do
    attachment.description = nil
    expect(attachment.save).to be false
  end

  it "should not save with a duplicate description for an attachable" do
    attachment.save!
    duplicate = build( :attachment, attachable: attachment.attachable,
      description: attachment.description )
    expect(duplicate.save).to be false
  end

  it "should not save without a document" do
    attachment.remove_document!
    expect(attachment.save).to be false
  end

end

