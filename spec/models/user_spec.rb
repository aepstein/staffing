require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @valid_attributes = {
      :first_name => "value for first_name",
      :middle_name => "value for middle_name",
      :last_name => "value for last_name",
      :email => "value for email",
      :mobile_phone => "value for mobile_phone",
      :work_phone => "value for work_phone",
      :home_phone => "value for home_phone",
      :work_address => "value for work_address",
      :date_of_birth => Date.today,
      :net_id => "value for net_id",
      :status => "value for status"
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@valid_attributes)
  end
end
