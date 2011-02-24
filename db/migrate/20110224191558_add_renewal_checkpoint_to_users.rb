class AddRenewalCheckpointToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :renewal_checkpoint, :datetime
    execute <<-SQL
      UPDATE users SET renewal_checkpoint = ( SELECT MIN( updated_at )
        FROM memberships WHERE memberships.user_id = users.id
      )
    SQL
    execute <<-SQL
      UPDATE users SET renewal_checkpoint = #{quote Time.zone.now}
      WHERE renewal_checkpoint IS NULL
    SQL
    change_column :users, :renewal_checkpoint, :datetime, :null => false
  end

  def self.down
    remove_column :users, :renewal_checkpoint
  end
end

