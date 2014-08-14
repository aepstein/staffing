require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Committee, :type => :model do
  before(:each) do
    @committee = create(:committee)
  end

  it "should create a new instance given valid attributes" do
    expect(@committee.id).not_to be_nil
  end

  it 'should not save without a name' do
    @committee.name = nil
    expect(@committee.save).to eql false
  end

  it 'should not save with a duplicate name' do
    duplicate = create(:committee)
    duplicate.name = @committee.name
    expect(duplicate.save).to eql false
  end

  it 'should not save without a schedule' do
    @committee.schedule = nil
    expect(@committee.save).to be false
  end

  it 'should have emails(:current) that returns emails of current members and designees' do
    designee = create(:designee)
    emails = designee.committee.emails(:current)
    expect(emails.length).to eql 2
    expect(emails).to include designee.user.name :email
    expect(emails).to include designee.membership.user.name :email
  end

  context "contact attributes" do
    let(:committee) { create(:committee, brand: create(:brand, phone: '2125551212')) }
    let(:attributes) { committee.contact_attributes }

    it "should return defaults except where overridden" do
      expect(Brand.contact_attributes[:phone]).not_to eql '2125551212'
      expect(attributes[:phone]).to eql '2125551212'
      expect(attributes[:fax]).to eql '6072552182'
      expect(attributes[:address_2]).to be_nil
    end
  end

end

