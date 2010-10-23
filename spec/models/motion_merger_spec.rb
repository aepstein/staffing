require 'spec_helper'

describe MotionMerger do
  before(:each) do
    @merger = Factory(:motion_merger)
  end

  it "should create a new instance given valid attributes" do
    @merger.id.should_not be_nil
  end
end

