require 'spec_helper'

describe User do
  before(:each) do
    @user = create(:user)
    @temporary_files = []
  end

  after(:each) do
    @temporary_files.each { |file| File.unlink file.path }
  end

  it "should create a new instance given valid attributes" do
    @user.id.should_not be_nil
  end

  it 'should not save without a net_id' do
    @user.net_id.should_not be_nil
  end

  it 'should not save with a duplicate net_id' do
    duplicate = build(:user)
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
    file = generate_uploaded_file(1.kilobyte, 'image/png', '.png')
    @user.resume = file
    @user.save.should be_false
  end

  it 'should have a name method that takes the :file argument' do
    @user.first_name = 'John'
    @user.last_name = 'Doe'
    @user.name(:file).should eql 'john-doe'
  end

  it 'should have an enrollments method that returns enrollments of a user' do
    m1 = create(:membership, :user => @user)
    m2 = create(:future_membership, :user => @user)
    m3 = create(:past_membership, :user => @user)
    m4 = create(:membership)
    e1 = create(:enrollment, :position => m1.position)
    e2 = create(:enrollment, :position => m2.position)
    e3 = create(:enrollment, :position => m3.position)
    e4 = create(:enrollment, :position => m4.position)
    @user.enrollments.length.should eql 3
    @user.enrollments.should include( e1, e2, e3 )
    @user.enrollments.current.length.should eql 1
    @user.enrollments.current.should include( e1 )
    @user.enrollments.future.length.should eql 1
    @user.enrollments.future.should include( e2 )
    @user.enrollments.past.length.should eql 1
    @user.enrollments.past.should include( e3 )
    @user.enrollments.prospective.length.should eql 2
    @user.enrollments.prospective.should include( e1, e2 )
  end

  it 'should have an authority_ids method that identifies the authorities in which the user is enrolled now or in the future' do
    memberships = {
      :current => create(:membership, :user => @user),
      :past => create(:past_membership, :user => @user),
      :future => create(:future_membership, :user => @user),
      :other => create(:membership)
    }
    committees = { }
    memberships.each { |key, membership| committees[key] = create(:enrollment, :position => membership.position).committee }
    authorities = { }
    authorities[:no_committee] = create(:authority)
    committees.each { |key, committee| authorities[key] = create(:authority, :committee => committee) }
    authorized = @user.authorities.authorized
    authorized.length.should eql 2
    authorized.should include authorities[:current]
    authorized.should include authorities[:future]
    create(:user).authorities.authorized.should be_empty
  end

  it 'should return authorized_position_ids based on authority_ids' do
    setup_authority_id_scenario
    @user.authorities.stub!(:authorized).and_return([@authorized])
    @user.authorized_position_ids.length.should eql 1
    @user.authorized_position_ids.should include @authorized.id
  end

  it 'should return empty authorized_position_ids if authority_ids is empty' do
    setup_authority_id_scenario
    create(:user).authorized_position_ids.should be_empty
  end

  it 'should return authorized_committee_ids based on authority_ids' do
    setup_authority_id_scenario
    @user.authorities.stub!(:authorized).and_return([@authorized])
    @user.authorized_committee_ids.length.should eql 1
    @user.authorized_committee_ids.should include @a_committee.id
  end

  it 'should return empty authorized_committee_ids if authority_ids is empty' do
    setup_authority_id_scenario
    create(:user).authorized_committee_ids.should be_empty
  end

  it 'should have no_renew_notice_since scope' do
    old = create(:user, :renew_notice_at => ( Time.zone.now - 1.week ) )
    recent = create(:user, :renew_notice_at => Time.zone.now )
    @user.renew_notice_at.should be_nil
    scope = User.no_renew_notice_since( Time.zone.now - 1.day )
    scope.count.should eql 2
    scope.should include @user
    scope.should include old
  end

  it 'should have a send_renew_notice! method' do
    @user.renew_notice_at.should be_nil
    @user.send_renew_notice!
    @user.renew_notice_at.should_not be_nil
  end

  it 'should have a to_email method that returns a valid email entry' do
    @user.to_email.should eql "#{@user.name} <#{@user.email}>"
  end

  def setup_authority_id_scenario
    @authorized = create(:position)
    @unauthorized = create(:position)
    @b_committee = create(:committee)
    @u_committee = create(:enrollment, :position => @unauthorized).committee
    @a_committee = create(:enrollment, :position => @authorized).committee
  end

  def generate_uploaded_file(size, type, extension = '.pdf')
    test_directory = "#{::Rails.root}/tmp/test"
    FileUtils.mkdir_p( test_directory )
    file = File.new("#{test_directory}/resume#{extension}", 'w')
    size.times { file << 'a' }
    file.close
    @temporary_files << file
    fixture_file_upload file.path, type
  end
end

