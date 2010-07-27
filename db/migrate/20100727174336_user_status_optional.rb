class UserStatusOptional < ActiveRecord::Migration
  def self.up
    say_with_time 'Shifting users to reflect elimination of "unknown" option' do
      rows = connection.update_sql "UPDATE users SET " +
      "statuses_mask = (statuses_mask - 64) WHERE (statuses_mask & 64) > 0"
      say "#{rows} records affected", true
    end
    say_with_time 'Shifting positions to reflect elimination of "unknown" option' do
      rows = connection.update_sql "UPDATE positions SET " +
      "statuses_mask = (statuses_mask - 64) WHERE (statuses_mask & 64) > 0"
      say "#{rows} records affected", true
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end

