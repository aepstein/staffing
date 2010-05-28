class AddDispositionToQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, :disposition, :string, :null => false, :default => 'string'
    say_with_time "Converting format to disposition for questions table..." do
      connection.update_sql 'UPDATE questions SET disposition = format'
    end
  end

  def self.down
    remove_column :questions, :disposition
  end
end

