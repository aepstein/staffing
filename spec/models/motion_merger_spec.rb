require 'spec_helper'

describe MotionMerger, :type => :model do

  let (:merger) { build( :motion_merger ) }

  it "should create a new instance given valid attributes" do
    merger.save!
  end

  it 'should merge the merged_motion' do
    merger.save!
    expect(merger.merged_motion.merged?).to be true
  end

  it 'should not save without a merged_motion' do
    merger.merged_motion = nil
    expect(merger.save).to be false
  end

  it 'should not save without a motion' do
    merger.motion = nil
    expect(merger.save).to be false
  end

end

