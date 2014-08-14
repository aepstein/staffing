require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Authority, :type => :model do
  before(:each) do
    @authority = create(:authority)
  end

  it "should create a new instance given valid attributes" do
    expect(@authority.id).not_to be_nil
  end

  it 'should not save without a name' do
    @authority.name = nil
    expect(@authority.save).to eql false
  end

  it 'should not save with a duplicate name' do
    duplicate = build(:authority)
    duplicate.name = @authority.name
    expect(duplicate.save).to eql false
  end

  it 'should have effective contact email' do
    @authority.contact_email = 'other@example.org'
    expect(@authority.contact_email).not_to eql Staffing::Application.app_config['defaults']['authority']['contact_email']
    expect(@authority.effective_contact_email).to eql @authority.contact_email
    @authority.contact_email = nil
    expect(@authority.effective_contact_email).to eql Staffing::Application.app_config['defaults']['authority']['contact_email']
  end

  it 'should have effective contact name' do
    @authority.contact_name = 'other@example.org'
    expect(@authority.contact_name).not_to eql Staffing::Application.app_config['defaults']['authority']['contact_name']
    expect(@authority.effective_contact_name).to eql @authority.contact_name
    @authority.contact_name = nil
    expect(@authority.effective_contact_name).to eql Staffing::Application.app_config['defaults']['authority']['contact_name']
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
      expect(@authority.membership_requests).to include membership_request
    end

    it "should retrieve membership_requests that are staffable with matching statuses_mask" do
      position.statuses = ['undergrad']
      position.save!
      user.status = 'undergrad'
      user.save!
      expect(@authority.membership_requests).to include membership_request
    end

    it "should not retrieve membership_requests that are not requestable" do
      membership_request
      enrollment.update_attribute :requestable, false
      expect(@authority.membership_requests).to be_empty
    end

    it "should not retrieve membership_requests that do not have status match" do
      membership_request
      position.statuses = ['undergrad']
      position.save!
      expect(user.status).not_to eql 'undergrad'
      expect(@authority.membership_requests).to be_empty
    end
  end

end

