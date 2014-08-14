require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Question, :type => :model do
  before(:each) do
    @question = create(:question)
  end

  it "should create a new instance given valid attributes" do
    expect(@question.id).not_to be_nil
  end

  it 'should not save without a name' do
    @question.name = nil
    expect(@question.save).to be false
  end

  it 'should not save with a duplicate name' do
    duplicate = build(:question)
    duplicate.name = @question.name
    expect(duplicate.save).to be false
  end

  it 'should not save without content' do
    @question.content = nil
    expect(@question.save).to be false
  end

  it 'should not save without a disposition' do
    @question.disposition = nil
    expect(@question.save).to be false
  end

  it 'should not save with an invalid disposition' do
    @question.disposition = 'invalid'
    expect(Question::DISPOSITIONS).not_to include @question.disposition
    expect(@question.save).to be false
  end
end

