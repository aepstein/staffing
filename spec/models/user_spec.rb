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

  def generate_uploaded_file(size, type)
    file = Tempfile.new('resume.pdf')
    @temporary_files << file
    size.times { file << 'a' }
    ActionController::TestUploadedFile.new(file.path,type)
  end
end

