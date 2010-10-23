require 'spec_helper'

describe MotionMerger do
  before(:each) do
    @merger = Factory(:motion_merger)
  end

  it "should create a new instance given valid attributes" do
    @merger.id.should_not be_nil
  end

  it 'should merge the merged_motion' do
    @merger.merged_motion.merged?.should be_true
  end

  it 'should not save without a merged_motion' do
    @merger.merged_motion = nil
    @merger.save.should be_false
  end

  it 'should not save without a motion' do
    @merger.motion = nil
    @merger.save.should be_false
  end

end

