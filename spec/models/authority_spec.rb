require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Authority do
  before(:each) do
    @authority = create(:authority)
  end

  it "should create a new instance given valid attributes" do
    @authority.id.should_not be_nil
  end

  it 'should not save without a name' do
    @authority.name = nil
    @authority.save.should eql false
  end

  it 'should not save with a duplicate name' do
    duplicate = build(:authority)
    duplicate.name = @authority.name
    duplicate.save.should eql false
  end

  it 'should have effective contact email' do
    @authority.contact_email = 'other@example.org'
    @authority.contact_email.should_not eql Staffing::Application.app_config['defaults']['authority']['contact_email']
    @authority.effective_contact_email.should eql @authority.contact_email
    @authority.contact_email = nil
    @authority.effective_contact_email.should eql Staffing::Application.app_config['defaults']['authority']['contact_email']
  end

  it 'should have effective contact name' do
    @authority.contact_name = 'other@example.org'
    @authority.contact_name.should_not eql Staffing::Application.app_config['defaults']['authority']['contact_name']
    @authority.effective_contact_name.should eql @authority.contact_name
    @authority.contact_name = nil
    @authority.effective_contact_name.should eql Staffing::Application.app_config['defaults']['authority']['contact_name']
  end

  it 'should retrieve associated requests correctly' do
    requests = [ ]
    requests << create(:request,
      committee: create(:enrollment, position: create(:position, authority: @authority),
      requestable: true ).committee )
    undergrad_committee = create(:enrollment, position: create(:position, authority: @authority,
    statuses: ['undergrad'] ), requestable: true ).committee
    requests << create(:request, committee: undergrad_committee,
      user: create(:user, statuses: ['undergrad']) )
    create(:request, committee: create(:enrollment, position: create(:position),
      requestable: true ).committee )
    requests.last.committee.enrollments.first.update_attribute! :requestable, false
    create(:enrollment, position: create(:position, statuses: ['grad']), committee: undergrad_committee )
    create(:request, committee: undergrad_committee, user: create(:user, :statuses => ['grad']) )
    @authority.requests.length.should eql 2
    requests.each { |request| @authority.requests.should include request }
    create(:authority).requests.to_a.should be_empty
  end

end

