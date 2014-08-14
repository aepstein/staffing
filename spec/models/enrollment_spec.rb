require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Enrollment, :type => :model do
  before(:each) do
    @enrollment = create(:enrollment)
  end

  it "should create a new instance given valid attributes" do
    expect(@enrollment.id).not_to be_nil
  end

  it 'should not save without a position' do
    @enrollment.position = nil
    expect(@enrollment.save).to be false
  end

  it 'should not save without a committee' do
    @enrollment.committee = nil
    expect(@enrollment.save).to be false
  end

  it 'should not save without a title' do
    @enrollment.title = nil
    expect(@enrollment.save).to be false
  end

  it 'should not save without a number of votes specified' do
    @enrollment.votes = nil
    expect(@enrollment.save).to be false
    @enrollment.votes = -1
    expect(@enrollment.save).to be false
  end

  context "roles" do
    it "should set roles correctly when roles array is supplied" do
      @enrollment.roles = %w( chair )
      expect(@enrollment.roles).to eq %w( chair )
    end
  end

end

