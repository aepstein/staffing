require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Question do
  before(:each) do
    @question = Factory(:question)
  end

  it "should create a new instance given valid attributes" do
    @question.id.should_not be_nil
  end

  it 'should not save without a name' do
    @question.name = nil
    @question.save.should be_false
  end

  it 'should not save with a duplicate name' do
    duplicate = Factory.build(:question)
    duplicate.name = @question.name
    duplicate.save.should be_false
  end

  it 'should not save without content' do
    @question.content = nil
    @question.save.should be_false
  end
end

