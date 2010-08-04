require 'spec_helper'

describe Motion do
  before(:each) do
    @motion = Factory(:motion)
  end

  it "should create a new instance given valid attributes" do
    @motion.id.should_not be_nil
  end
end

