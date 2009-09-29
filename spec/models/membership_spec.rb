require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Membership do
  before(:each) do
    @valid_attributes = {
      :user_id => 1,
      :term_id => 1,
      :position_id => 1,
      :request_id => 1,
      :starts_at => Date.today,
      :ends_at => Date.today
    }
  end

  it "should create a new instance given valid attributes" do
    Membership.create!(@valid_attributes)
  end
end
