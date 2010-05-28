class RemoveFormatFromQuestion < ActiveRecord::Migration
  def self.up
    remove_column :questions, :format
  end

  def self.down
    add_column :questions, :format, :string
    say_with_time "Converting disposition to format for questions model..." do
      connection.update_sql 'UPDATE questions SET format = disposition'
    end
  end
end

