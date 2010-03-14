class AddFormatToQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, :format, :string, :null => false, :default => 'string'
  end

  def self.down
    remove_column :questions, :format
  end
end

