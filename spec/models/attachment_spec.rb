require 'spec_helper'

describe Attachment do

  let(:attachment) { build :attachment }

  it "should save with valid attributes" do
    attachment.save!
  end

  it "should not save without an attachable" do
    attachment.attachable = nil
    attachment.save.should be_false
  end

  it "should not save without a description" do
    attachment.description = nil
    attachment.save.should be_false
  end

  it "should not save with a duplicate description for an attachable" do
    attachment.save!
    duplicate = build( :attachment, attachable: attachment.attachable,
      description: attachment.description )
    duplicate.save.should be_false
  end

  it "should not save without a document" do
    attachment.remove_document!
    attachment.save.should be_false
  end

end

