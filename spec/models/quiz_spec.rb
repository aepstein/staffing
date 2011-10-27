require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Quiz do
  before(:each) do
    @quiz = create(:quiz)
  end

  it "should create a new instance given valid attributes" do
    @quiz.id.should_not be_nil
  end

  it 'should not save without a name' do
    @quiz.name = nil
    @quiz.save.should eql false
  end

  it 'should not save with a duplicate name' do
    duplicate = build(:quiz)
    duplicate.name = @quiz.name
    duplicate.save.should eql false
  end
end

