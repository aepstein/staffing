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

end

