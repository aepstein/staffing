class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.string :name
      t.text :content
      t.boolean :global

      t.timestamps
    end
    add_index :questions, :name, :unique => true
  end

  def self.down
    drop_table :questions
  end
end

