require 'spec_helper'

describe 'VectorUploader' do
  include CarrierWave::Test::Matchers

  before do
    VectorUploader.enable_processing = true
    @uploader = Factory(:logo).vector
  end

  after do
    VectorUploader.enable_processing = false
  end

  context 'tent version' do
    it 'should scale to ~1927 pixels by 600 pixels' do
      @uploader.tent.should have_dimensions( 1925, 600 )
    end
  end

  context 'letterhead version' do
    it 'should scale to ~1695 pixels by 528 pixels' do
      @uploader.letterhead.should have_dimensions( 1697, 528 )
    end
  end

end

