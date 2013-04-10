class CreateMotionComments < ActiveRecord::Migration
  def change
    create_table :motion_comments do |t|
      t.references :motion, null: false
      t.references :user, null: false
      t.text :comment

      t.timestamps
    end
    add_index :motion_comments, :motion_id
    add_index :motion_comments, :user_id
  end
end

