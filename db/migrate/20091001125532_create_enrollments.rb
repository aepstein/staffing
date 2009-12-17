class CreateEnrollments < ActiveRecord::Migration
  def self.up
    create_table :enrollments do |t|
      t.references :position, :null => false
      t.references :committee, :null => false
      t.string :title, :null => false
      t.integer :votes, :null => false, :default => 1

      t.timestamps
    end
    add_index :enrollments, [ :committee_id, :title ]
  end

  def self.down
    drop_table :enrollments
  end
end

