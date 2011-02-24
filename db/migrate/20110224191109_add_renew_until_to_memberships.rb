class AddRenewUntilToMemberships < ActiveRecord::Migration
  def self.up
    add_column :memberships, :renew_until, :date
    execute <<-SQL
      UPDATE memberships SET renew_until = ( SELECT MAX( requests.ends_at )
        FROM requests WHERE memberships.request_id = requests.id AND
        requests.ends_at > memberships.ends_at
      )
    SQL
  end

  def self.down
    remove_column :memberships, :renew_until
  end
end

