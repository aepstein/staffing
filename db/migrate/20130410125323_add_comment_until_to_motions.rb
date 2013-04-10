class AddCommentUntilToMotions < ActiveRecord::Migration
  def change
    add_column :motions, :comment_until, :datetime
  end
end
