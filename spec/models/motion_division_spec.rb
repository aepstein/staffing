require 'spec_helper'

describe MotionDivision do
  before(:each) do
    @valid_attributes = {
      :divided_motion_id => 1,
      :motion_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    MotionDivision.create!(@valid_attributes)
  end
end
