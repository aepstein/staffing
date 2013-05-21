require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Committee do
  before(:each) do
    @committee = create(:committee)
  end

  it "should create a new instance given valid attributes" do
    @committee.id.should_not be_nil
  end

  it 'should not save without a name' do
    @committee.name = nil
    @committee.save.should eql false
  end

  it 'should not save with a duplicate name' do
    duplicate = create(:committee)
    duplicate.name = @committee.name
    duplicate.save.should eql false
  end

  it 'should not save without a schedule' do
    @committee.schedule = nil
    @committee.save.should be_false
  end

  it 'should have emails(:current) that returns emails of current members and designees' do
    designee = create(:designee)
    emails = designee.committee.emails(:current)
    emails.length.should eql 2
    emails.should include designee.user.name :email
    emails.should include designee.membership.user.name :email
  end

  context "contact attributes" do
    let(:committee) { create(:committee, brand: create(:brand, phone: '2125551212')) }
    let(:attributes) { committee.contact_attributes }

    it "should return defaults except where overridden" do
      Brand.contact_attributes[:phone].should_not eql '2125551212'
      attributes[:phone].should eql '2125551212'
      attributes[:fax].should eql '6072552182'
      attributes[:address_2].should be_nil
    end
  end

end

