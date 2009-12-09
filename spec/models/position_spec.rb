require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Position do
  before(:each) do
    @position = Factory(:position)
  end

  it "should create a new instance given valid attributes" do
    @position.id.should_not be_nil
  end

  it 'should not save without a name' do
    @position.name = nil
    @position.save.should be_false
  end

  it 'should not save with a duplicate name' do
    duplicate = Factory.build(:position, :name => @position.name)
    duplicate.save.should be_false
  end

  it 'should not save without an authority' do
    @position.authority = nil
    @position.save.should be_false
  end

  it 'should not save without a quiz' do
    @position.quiz = nil
    @position.save.should be_false
  end

  it 'should not save without a schedule' do
    @position.schedule = nil
    @position.save.should be_false
  end

  it 'should not save without a number of slots specified' do
    @position.slots = nil
    @position.save.should be_false
    @position.slots = ""
    @position.save.should be_false
    @position.slots = -1
    @position.save.should be_false
  end
end

