require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Committee do
  before(:each) do
    @committee = Factory(:committee)
  end

  it "should create a new instance given valid attributes" do
    @committee.id.should_not be_nil
  end

  it 'should not save without a name' do
    @committee.name = nil
    @committee.save.should eql false
  end

  it 'should not save with a duplicate name' do
    duplicate = Factory(:committee)
    duplicate.name = @committee.name
    duplicate.save.should eql false
  end

  it 'should have current_emails that returns emails of current members and designees' do
    designee = Factory(:designee)
    emails = designee.committee.current_emails
    emails.length.should eql 2
    emails.should include designee.user.name :email
    emails.should include designee.membership.user.name :email
  end
end

