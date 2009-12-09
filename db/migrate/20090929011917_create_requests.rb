class CreateRequests < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|
      t.references :position, :null => false
      t.references :user, :null => false
      t.string :state

      t.timestamps
    end
    create_table :requests_terms, :id => false do |t|
      t.references :request, :null => false
      t.references :term, :null => false
    end
    add_index :requests_terms, [ :request_id, :term_id ], :unique => true
  end

  def self.down
    drop_table :requests_terms
    drop_table :requests
  end
end

