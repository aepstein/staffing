class AddPublishedToMotions < ActiveRecord::Migration
  def change
    add_column :motions, :published, :boolean, null: false, default: false
  end
end

