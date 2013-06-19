class AddVotesToMotionEvents < ActiveRecord::Migration
  def change
    add_column :motion_events, :unrecorded_affirmative_votes, :integer
    add_column :motion_events, :unrecorded_negative_votes, :integer
    add_column :motion_events, :unrecorded_present_votes, :integer
  end
end
