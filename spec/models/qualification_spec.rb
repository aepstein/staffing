require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Qualification do
  before(:each) do
    @qualification = create(:qualification)
  end

  it "should create a new instance given valid attributes" do
    @qualification.id.should_not be_nil
  end

  it 'should not save without a name' do
    @qualification.name = nil
    @qualification.save.should be_false
  end

  it 'should not save with a duplicate name' do
    duplicate = build(:qualification)
    duplicate.name = @qualification.name
    duplicate.save.should be_false
  end
end

