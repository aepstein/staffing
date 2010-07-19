class AddNotifiableToPosition < ActiveRecord::Migration
  def self.up
    add_column :positions, :notifiable, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :positions, :notifiable
  end
end

