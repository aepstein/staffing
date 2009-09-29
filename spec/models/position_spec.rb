require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Position do
  before(:each) do
    @valid_attributes = {
      :authority_id => 1,
      :committee_id => 1,
      :quiz_id => 1,
      :schedule_id => 1,
      :slots => 1,
      :voting => false,
      :name => "value for name"
    }
  end

  it "should create a new instance given valid attributes" do
    Position.create!(@valid_attributes)
  end
end
