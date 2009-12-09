class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.string :name
      t.text :content
      t.boolean :global

      t.timestamps
    end
    add_index :questions, :name, :unique => true
    create_table :questions_quizzes, :id => false do |t|
      t.references :question, :null => false
      t.references :quiz, :null => false
    end
    add_index :questions_quizzes, [ :question_id, :quiz_id ], :unique => true
  end

  def self.down
    drop_table :questions_quizzes
    drop_table :questions
  end
end

