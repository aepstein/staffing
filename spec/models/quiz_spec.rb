require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Quiz, :type => :model do
  before(:each) do
    @quiz = create(:quiz)
  end

  it "should create a new instance given valid attributes" do
    expect(@quiz.id).not_to be_nil
  end

  it 'should not save without a name' do
    @quiz.name = nil
    expect(@quiz.save).to eql false
  end

  it 'should not save with a duplicate name' do
    duplicate = build(:quiz)
    duplicate.name = @quiz.name
    expect(duplicate.save).to eql false
  end
end

