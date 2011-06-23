require 'spec_helper'

describe 'VectorUploader' do
  include CarrierWave::Test::Matchers

  before do
    VectorUploader.enable_processing = true
    @uploader = Factory(:brand).logo
  end

  after do
    VectorUploader.enable_processing = false
  end

  context 'original version' do
    it 'should save with original extension' do
      File.extname( @uploader.store_path ).should eql '.eps'
    end
  end

  context 'thumb version' do
    it 'should scale within 100x100 pixels' do
      @uploader.thumb.should be_no_larger_than( 100, 100 )
    end
    it 'should save with png extension' do
      File.extname( @uploader.thumb.store_path ).should eql '.png'
    end
  end

  context 'tent version' do
    it 'should scale to ~1927 pixels by 600 pixels' do
      @uploader.tent.should have_dimensions( 1925, 600 )
    end
    it 'should save with png extension' do
      File.extname( @uploader.tent.store_path ).should eql '.png'
    end
  end

  context 'letterhead version' do
    it 'should scale to ~1695 pixels by 528 pixels' do
      @uploader.letterhead.should have_dimensions( 1697, 528 )
    end
    it 'should save with png extension' do
      File.extname( @uploader.letterhead.store_path ).should eql '.png'
    end
  end

end

