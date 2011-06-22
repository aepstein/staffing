require 'spec_helper'

describe Logo do

  before(:each) do
    @logo = Factory(:logo)
  end

  it 'should save with valid attributes' do
    @logo.id.should_not be_nil
  end

  it 'should not save without a name' do
    @logo.name = nil
    @logo.save.should be_false
  end

  it 'should not save with a duplicate name' do
    duplicate = Factory.build(:logo, :name => @logo.name)
    duplicate.save.should be_false
  end

  it 'should not save without a vector file' do
    @logo.remove_vector!
    @logo.save.should be_false
  end

end

