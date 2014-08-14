require 'spec_helper'

describe User, :type => :model do
  before(:each) do
    @user = create(:user)
    @temporary_files = []
  end

  after(:each) do
    @temporary_files.each { |file| File.unlink file.path }
  end

  it "should create a new instance given valid attributes" do
    expect(@user.id).not_to be_nil
  end

  it 'should not save without a net_id' do
    expect(@user.net_id).not_to be_nil
  end

  it 'should not save with a duplicate net_id' do
    duplicate = build(:user)
    duplicate.net_id = @user.net_id
    expect(duplicate.save).to be false
  end

  it "should not save with duplicate empl_id" do
    @user.update_attribute :empl_id, 10000
    duplicate = build(:user)
    duplicate.empl_id = @user.empl_id
    expect(duplicate.save).to be false
  end

  it 'should not save without a first name' do
    @user.first_name = nil
    expect(@user.save).to be false
  end

  it 'should not save without a last name' do
    @user.last_name = nil
    expect(@user.save).to be false
  end

  it 'should not save without email' do
    @user.email = nil
    expect(@user.save).to be false
  end

  it 'should save with a resume of correct size and type' do
    file = generate_uploaded_file(1.kilobyte, 'application/pdf')
    @user.resume = file
    expect(@user.save).to be true
  end

  it 'should not save with a resume that is too large' do
    file = generate_uploaded_file(2.megabytes, 'application/pdf')
    @user.resume = file
    expect(@user.save).to be false
  end

  it 'should not save with a resume that is of the wrong type' do
    file = generate_uploaded_file(1.kilobyte, 'image/png', '.png')
    @user.resume = file
    expect(@user.save).to be false
  end

  it 'should have a name method that takes the :file argument' do
    @user.first_name = 'John'
    @user.last_name = 'Doe'
    expect(@user.name(:file)).to eql 'john-doe'
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
    expect(@user.enrollments.length).to eql 3
    expect(@user.enrollments).to include( e1, e2, e3 )
    expect(@user.enrollments.current.length).to eql 1
    expect(@user.enrollments.current).to include( e1 )
    expect(@user.enrollments.future.length).to eql 1
    expect(@user.enrollments.future).to include( e2 )
    expect(@user.enrollments.past.length).to eql 1
    expect(@user.enrollments.past).to include( e3 )
    expect(@user.enrollments.prospective.length).to eql 2
    expect(@user.enrollments.prospective).to include( e1, e2 )
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
    expect(authorized.length).to eql 2
    expect(authorized).to include authorities[:current]
    expect(authorized).to include authorities[:future]
    expect(create(:user).authorities.authorized).to be_empty
  end

  it 'should return positions.authorized based on authorities' do
    setup_authority_id_scenario
    create(:membership, :user => @user, :position => @authority)
    expect(@user.positions.authorized.length).to eql 1
    expect(@user.positions.authorized).to include @authorized
  end

  it 'should return empty positions.authorized if authorities is empty' do
    setup_authority_id_scenario
    expect(create(:user).positions.authorized).to be_empty
  end

  it 'should return committees.authorized based on authorities' do
    setup_authority_id_scenario
    create(:membership, :user => @user, :position => @authority)
    expect(@user.committees.authorized.length).to eql 1
    expect(@user.committees.authorized).to include @a_committee
  end

  it 'should return empty committees.authorized if authorities is empty' do
    setup_authority_id_scenario
    expect(create(:user).committees.authorized).to be_empty
  end

  it 'should have no_renew_notice_since scope' do
    old = create(:user)
    create(:notice, notifiable: old, event: 'renew').update_column(
      :created_at, (Time.zone.now - 1.week) )
    recent = create(:user)
    create(:notice, notifiable: recent, event: 'renew').update_column(
      :created_at, Time.zone.now)
    expect(@user.notices.for_event('renew')).to be_empty
    scope = User.no_renew_notice_since( Time.zone.now - 1.day )
    expect(scope.count).to eql 2
    expect(scope).to include @user
    expect(scope).to include old
  end

  it 'should have a send_renew_notice! method' do
    expect(@user.notices.for_event('renew')).to be_empty
    @user.send_renew_notice!
    @user.association(:notices).reset
    expect(@user.notices.for_event('renew')).not_to be_empty
  end

  it 'should have a to_email method that returns a valid email entry' do
    expect(@user.to_email).to eql "#{@user.name} <#{@user.email}>"
  end

  it "should import empl_id from csv string" do
    expect(@user.empl_id).to be_nil
    str = "\"#{@user.net_id}\",10000
\"o#{@user.net_id}\",10001"
    expect(User.import_empl_id_from_csv_string( str )).to eql 1
    @user.reload
    expect(@user.empl_id).to eql 10000
  end

  context 'role symbols' do

    let(:user) { build :user }

    it "should return [:user] only for regular user" do
      expect(user.role_symbols).to include(:user)
      expect(user.role_symbols).not_to include(:admin)
    end

    it "should return [:user,:admin] admin user" do
      user.admin = true
      expect(user.role_symbols).to include(:user,:admin)
    end
  end

  def setup_authority_id_scenario
    @authorized = create(:position)
    @unauthorized = create(:position)
    @b_committee = create(:committee)
    @u_committee = create(:enrollment, :position => @unauthorized).committee
    @a_committee = create(:enrollment, :position => @authorized).committee
    @enrollment = create(:enrollment, :votes => 1)
    @authorized.authority.update_attribute :committee, @enrollment.committee
    @authority = @enrollment.position
  end

  def generate_uploaded_file(size, type, extension = '.pdf')
    test_directory = "#{::Rails.root}/tmp/test"
    FileUtils.mkdir_p( test_directory )
    file = File.new("#{test_directory}/resume#{extension}", 'w')
    size.times { file << 'a' }
    file.close
    @temporary_files << file
    Rack::Test::UploadedFile.new file.path, type
  end
end

