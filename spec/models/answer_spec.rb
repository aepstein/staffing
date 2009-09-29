require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Answer do
  before(:each) do
    @valid_attributes = {
      :question_id => 1,
      :request_id => 1,
      :content => "value for content"
    }
  end

  it "should create a new instance given valid attributes" do
    Answer.create!(@valid_attributes)
  end
end
