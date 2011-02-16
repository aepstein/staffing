class CreateSponsorships < ActiveRecord::Migration
  def self.up
    create_table :sponsorships do |t|
      t.references :motion, :null => false
      t.references :user, :null => false

      t.timestamps
    end
    add_index :sponsorships, [ :motion_id, :user_id ], :unique => true
    execute <<-SQL
      INSERT INTO sponsorships ( motion_id, user_id, created_at, updated_at )
      SELECT id, user_id, created_at, updated_at FROM motions
    SQL
    remove_column :motions, :user_id
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end

