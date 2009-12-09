require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Term do
  before(:each) do
    @term = Factory(:term)
  end

  it "should create a new instance given valid attributes" do
    @term.id.should_not be_nil
  end

  it 'should not save without a start date' do
    @term.starts_at = nil
    @term.save.should be_false
  end

  it 'should not save without an end date' do
    @term.ends_at = nil
    @term.save.should be_false
  end

  it 'should not save with an end date that is before the start date' do
    @term.ends_at = @term.starts_at - 1.day
    @term.save.should be_false
  end
end

