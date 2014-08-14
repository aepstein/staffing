require 'spec_helper'

describe Brand, :type => :model do

  before(:each) do
    @brand = create(:brand)
  end

  it 'should save with valid attributes' do
    expect(@brand.id).not_to be_nil
  end

  it 'should not save without a name' do
    @brand.name = nil
    expect(@brand.save).to be false
  end

  it 'should not save with a duplicate name' do
    duplicate = build(:brand, :name => @brand.name)
    expect(duplicate.save).to be false
  end

  it 'should not save without a logo file' do
    @brand.remove_logo!
    expect(@brand.save).to be false
  end

end

