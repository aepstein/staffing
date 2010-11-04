require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Authority do
  before(:each) do
    @authority = Factory(:authority)
  end

  it "should create a new instance given valid attributes" do
    @authority.id.should_not be_nil
  end

  it 'should not save without a name' do
    @authority.name = nil
    @authority.save.should eql false
  end

  it 'should not save with a duplicate name' do
    duplicate = Factory.build(:authority)
    duplicate.name = @authority.name
    duplicate.save.should eql false
  end

  it 'should have effective contact email' do
    @authority.contact_email = 'other@example.org'
    @authority.contact_email.should_not eql APP_CONFIG['defaults']['authority']['contact_email']
    @authority.effective_contact_email.should eql @authority.contact_email
    @authority.contact_email = nil
    @authority.effective_contact_email.should eql APP_CONFIG['defaults']['authority']['contact_email']
  end

  it 'should have effective contact name' do
    @authority.contact_name = 'other@example.org'
    @authority.contact_name.should_not eql APP_CONFIG['defaults']['authority']['contact_name']
    @authority.effective_contact_name.should eql @authority.contact_name
    @authority.contact_name = nil
    @authority.effective_contact_name.should eql APP_CONFIG['defaults']['authority']['contact_name']
  end

  it 'should retrieve associated requests correctly' do
    requests = [ ]
    requests << Factory(:request, :requestable => Factory(:position, :requestable => true, :authority => @authority) )
    requests << Factory(:request, :requestable => Factory(:enrollment, :position => Factory(:position, :requestable => false, :requestable_by_committee => true, :authority => @authority) ).committee )
    undergrad_committee = Factory(:enrollment, :position => Factory(:position, :requestable => false, :requestable_by_committee => true, :authority => @authority, :statuses => ['undergrad'] ) ).committee
    requests << Factory(:request, :requestable => undergrad_committee, :user => Factory(:user, :statuses => ['undergrad']) )
    Factory(:request, :requestable => Factory(:position, :requestable => true) )
    Factory(:request, :requestable => Factory(:enrollment, :position => Factory(:position, :requestable => false) ).committee )
    Factory(:enrollment, :position => Factory(:position, :requestable => false, :statuses => ['grad']), :committee => undergrad_committee )
    Factory(:request, :requestable => undergrad_committee, :user => Factory(:user, :statuses => ['grad']) )
    @authority.requests.length.should eql 3
    requests.each { |request| @authority.requests.should include request }
    Factory(:authority).requests.to_a.should be_empty
  end

end

