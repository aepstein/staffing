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

  context "membership_requests" do
    def position
      @position ||= create(:position, authority: @authority)
    end

    def enrollment
      @enrollment ||= create(:enrollment, position: position, requestable: true)
    end

    def committee
      enrollment.committee
    end

    def membership_request
      @membership_request ||= create(:membership_request, user: user, committee: committee)
    end

    def user
      @user ||= create(:user)
    end

    it "should retrieve membership_requests that are staffable with no statuses_mask" do
      @authority.membership_requests.should include membership_request
    end

    it "should retrieve membership_requests that are staffable with matching statuses_mask" do
      position.statuses = ['undergrad']
      position.save!
      user.status = 'undergrad'
      user.save!
      @authority.membership_requests.should include membership_request
    end

    it "should not retrieve membership_requests that are not requestable" do
      membership_request
      enrollment.update_attribute :requestable, false
      @authority.membership_requests.should be_empty
    end

    it "should not retrieve membership_requests that do not have status match" do
      membership_request
      position.statuses = ['undergrad']
      position.save!
      user.status.should_not eql 'undergrad'
      @authority.membership_requests.should be_empty
    end
  end

end

