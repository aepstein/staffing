class CreateTerms < ActiveRecord::Migration
  def self.up
    create_table :terms do |t|
      t.references :schedule
      t.date :starts_at
      t.date :ends_at

      t.timestamps
    end
  end

  def self.down
    drop_table :terms
  end
end

