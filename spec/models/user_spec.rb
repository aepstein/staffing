require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @user = Factory(:user)
    @temporary_files = []
  end

  after(:each) do
    @temporary_files.each { |file| file.close! }
  end

  it "should create a new instance given valid attributes" do
    @user.id.should_not be_nil
  end

  it 'should not save without a net_id' do
    @user.net_id.should_not be_nil
  end

  it 'should not save with a duplicate net_id' do
    duplicate = Factory.build(:user)
    duplicate.net_id = @user.net_id
    duplicate.save.should be_false
  end

  it 'should not save without a first name' do
    @user.first_name = nil
    @user.save.should be_false
  end

  it 'should not save without a last name' do
    @user.last_name = nil
    @user.save.should be_false
  end

  it 'should not save without email' do
    @user.email = nil
    @user.save.should be_false
  end

  it 'should save with a resume of correct size and type' do
    file = generate_uploaded_file(1.kilobyte, 'application/pdf')
    @user.resume = file
    @user.save.should be_true
  end

  it 'should not save with a resume that is too large' do
    file = generate_uploaded_file(2.megabytes, 'application/pdf')
    @user.resume = file
    @user.save.should be_false
  end

  it 'should not save with a resume that is of the wrong type' do
    file = generate_uploaded_file(1.kilobyte, 'image/png')
    @user.resume = file
    @user.save.should be_false
  end

  it 'should have a name method that takes the :file argument' do
    @user.first_name = 'John'
    @user.last_name = 'Doe'
    @user.name(:file).should eql 'john-doe'
  end

  it 'should have an enrollments method that returns enrollments of a user' do
    m1 = Factory(:membership, :user => @user)
    m2 = Factory(:future_membership, :user => @user)
    m3 = Factory(:past_membership, :user => @user)
    m4 = Factory(:membership)
    e1 = Factory(:enrollment, :position => m1.position)
    e2 = Factory(:enrollment, :position => m2.position)
    e3 = Factory(:enrollment, :position => m3.position)
    e4 = Factory(:enrollment, :position => m4.position)
    @user.enrollments.length.should eql 3
    @user.enrollments.should include( e1, e2, e3 )
    @user.current_enrollments.length.should eql 1
    @user.current_enrollments.should include( e1 )
    @user.future_enrollments.length.should eql 1
    @user.future_enrollments.should include( e2 )
    @user.past_enrollments.length.should eql 1
    @user.past_enrollments.should include( e3 )
  end

  it 'should have an authority_ids method that identifies the authorities in which the user is enrolled now or in the future' do
    memberships = {
      :current => Factory(:membership, :user => @user),
      :past => Factory(:past_membership, :user => @user),
      :future => Factory(:future_membership, :user => @user),
      :other => Factory(:membership)
    }
    committees = { }
    memberships.each { |key, membership| committees[key] = Factory(:enrollment, :position => membership.position).committee }
    authorities = { }
    authorities[:no_committee] = Factory(:authority)
    committees.each { |key, committee| authorities[key] = Factory(:authority, :committee => committee) }
    @user.authority_ids.length.should eql 2
    @user.authority_ids.should include authorities[:current].id
    @user.authority_ids.should include authorities[:future].id
    Factory(:user).authority_ids.should be_empty
  end

  it 'should return authorized_position_ids based on authority_ids' do
    setup_authority_id_scenario
    @user.stub!(:authority_ids).and_return([@authorized.authority_id])
    @user.authorized_position_ids.length.should eql 1
    @user.authorized_position_ids.should include @authorized.id
  end

  it 'should return empty authorized_position_ids if authority_ids is empty' do
    setup_authority_id_scenario
    Factory(:user).authorized_position_ids.should be_empty
  end

  it 'should return authorized_committee_ids based on authority_ids' do
    setup_authority_id_scenario
    @user.stub!(:authority_ids).and_return([@authorized.authority_id])
    @user.authorized_committee_ids.length.should eql 1
    @user.authorized_committee_ids.should include @a_committee.id
  end

  it 'should return empty authorized_committee_ids if authority_ids is empty' do
    setup_authority_id_scenario
    Factory(:user).authorized_committee_ids.should be_empty
  end

  def setup_authority_id_scenario
    @authorized = Factory(:position)
    @unauthorized = Factory(:position)
    @b_committee = Factory(:committee)
    @u_committee = Factory(:enrollment, :position => @unauthorized).committee
    @a_committee = Factory(:enrollment, :position => @authorized).committee
  end

  def generate_uploaded_file(size, type)
    file = Tempfile.new('resume.pdf')
    @temporary_files << file
    size.times { file << 'a' }
    fixture_file_upload file.path, type
  end
end

