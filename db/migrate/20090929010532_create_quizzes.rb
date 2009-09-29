class CreateQuizzes < ActiveRecord::Migration
  def self.up
    create_table :quizzes do |t|
      t.string :name

      t.timestamps
    end
    add_index :quizzes, :name, :unique => true
  end

  def self.down
    drop_table :quizzes
  end
end

