require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Term do
  before(:each) do
    @valid_attributes = {
      :schedule_id => 1,
      :starts_at => Date.today,
      :ends_at => Date.today
    }
  end

  it "should create a new instance given valid attributes" do
    Term.create!(@valid_attributes)
  end
end
