require 'spec_helper'

describe MotionMerger do
  before(:each) do
    @valid_attributes = {
      :merged_motion_id => 1,
      :motion_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    MotionMerger.create!(@valid_attributes)
  end
end
