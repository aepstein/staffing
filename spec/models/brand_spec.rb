require 'spec_helper'

describe Brand do

  before(:each) do
    @brand = create(:brand)
  end

  it 'should save with valid attributes' do
    @brand.id.should_not be_nil
  end

  it 'should not save without a name' do
    @brand.name = nil
    @brand.save.should be_false
  end

  it 'should not save with a duplicate name' do
    duplicate = build(:brand, :name => @brand.name)
    duplicate.save.should be_false
  end

  it 'should not save without a logo file' do
    @brand.remove_logo!
    @brand.save.should be_false
  end

end

