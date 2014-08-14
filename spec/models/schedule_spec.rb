require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Schedule, :type => :model do
  before(:each) do
    @schedule = create(:schedule)
  end

  it "should create a new instance given valid attributes" do
    expect(@schedule.id).not_to be_nil
  end

  it 'should not save without a name' do
    @schedule.name = nil
    expect(@schedule.save).to eql false
  end

  it 'should not save with a duplicate name' do
    duplicate = build(:schedule)
    duplicate.name = @schedule.name
    expect(duplicate.save).to eql false
  end
end

