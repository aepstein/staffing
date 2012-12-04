require 'spec_helper'

describe MotionMerger do

  let (:merger) { build( :motion_merger ) }

  it "should create a new instance given valid attributes" do
    merger.save!
  end

  it 'should merge the merged_motion' do
    merger.save!
    merger.merged_motion.merged?.should be_true
  end

  it 'should not save without a merged_motion' do
    merger.merged_motion = nil
    merger.save.should be_false
  end

  it 'should not save without a motion' do
    merger.motion = nil
    merger.save.should be_false
  end

end

