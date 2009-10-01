require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Enrollment do
  before(:each) do
    @valid_attributes = {
      :position_id => 1,
      :committee_id => 1,
      :title => "value for title",
      :votes => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Enrollment.create!(@valid_attributes)
  end
end
