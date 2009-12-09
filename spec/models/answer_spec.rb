require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Answer do
  before(:each) do
    @answer = Factory(:answer)
  end

  it "should create a new instance given valid attributes" do
    @answer.id.should_not be_nil
  end

  it 'should not save without a question' do
    @answer.question = nil
    @answer.save.should be_false
  end

  it 'should not save without a request' do
    @answer.request = nil
    @answer.save.should be_false
  end
end

