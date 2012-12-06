class CreateQuizQuestions < ActiveRecord::Migration
  def change
    create_table :quiz_questions do |t|
      t.references :quiz, null: false
      t.references :question, null: false
      t.integer :position, null: false

      t.timestamps
    end
    add_index :quiz_questions, :quiz_id
    add_index :quiz_questions, :question_id
    add_index :quiz_questions, [ :quiz_id, :question_id ], unique: true
  end
end

