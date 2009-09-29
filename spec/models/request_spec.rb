require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Request do
  before(:each) do
    @valid_attributes = {
      :term_id => 1,
      :position_id => 1,
      :user_id => 1,
      :state => "value for state"
    }
  end

  it "should create a new instance given valid attributes" do
    Request.create!(@valid_attributes)
  end
end
