class AddDesignableToPosition < ActiveRecord::Migration
  def self.up
    add_column :positions, :designable, :boolean
    add_index :positions, :designable
    execute "UPDATE positions SET designable = #{connection.quote true} " +
      "WHERE id IN ( SELECT position_id FROM memberships, designees " +
      "WHERE memberships.id = designees.membership_id )"
  end

  def self.down
    remove_index :positions, :designable
    remove_column :positions, :designable
  end
end

