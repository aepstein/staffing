class AddStatusesMaskToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :statuses_mask, :integer, :null => false, :default => 0
    say_with_time "Converting status to statuses_mask" do
      User::STATUSES.each do |status|
        rows = connection.update_sql "UPDATE users SET statuses_mask = #{2**User::STATUSES.index(status)} " +
        "WHERE status = #{connection.quote status}"
        say("#{rows} with status #{status}", true)
      end
    end
  end

  def self.down
    remove_column :users, :statuses_mask
  end
end

