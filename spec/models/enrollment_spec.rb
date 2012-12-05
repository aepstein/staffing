require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Enrollment do
  before(:each) do
    @enrollment = create(:enrollment)
  end

  it "should create a new instance given valid attributes" do
    @enrollment.id.should_not be_nil
  end

  it 'should not save without a position' do
    @enrollment.position = nil
    @enrollment.save.should be_false
  end

  it 'should not save without a committee' do
    @enrollment.committee = nil
    @enrollment.save.should be_false
  end

  it 'should not save without a title' do
    @enrollment.title = nil
    @enrollment.save.should be_false
  end

  it 'should not save without a number of votes specified' do
    @enrollment.votes = nil
    @enrollment.save.should be_false
    @enrollment.votes = -1
    @enrollment.save.should be_false
  end

  context "roles" do
    it "should set roles correctly when roles array is supplied" do
      @enrollment.roles = %w( chair )
      @enrollment.roles.should eq %w( chair )
    end
  end

end

