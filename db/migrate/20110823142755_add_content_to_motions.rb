class AddContentToMotions < ActiveRecord::Migration
  def self.up
    add_column :motions, :content, :text
  end

  def self.down
    remove_column :motions, :content
  end
end
