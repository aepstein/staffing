class DropQuestionsQuizzes < ActiveRecord::Migration
  def up
    execute <<-SQL
      INSERT INTO quiz_questions ( quiz_id, question_id, position,
        created_at, updated_at )
      SELECT quiz_id, question_id, ( SELECT COUNT(*) FROM questions_quizzes
      AS priors INNER JOIN questions AS prior_questions ON priors.question_id = prior_questions.id
      WHERE prior_questions.name < questions.name AND
      priors.quiz_id = questions_quizzes.quiz_id ) + 1 AS position,
      questions.created_at, questions.updated_at
      FROM questions_quizzes INNER JOIN questions
      ON questions_quizzes.question_id = questions.id
    SQL
    remove_index :questions_quizzes, [ :question_id, :quiz_id ]
    drop_table :questions_quizzes
  end

  def down
    create_table :questions_quizzes, :id => false, :force => true do |t|
      t.integer :question_id, :null => false
      t.integer :quiz_id,     :null => false
    end
    add_index :questions_quizzes, [:question_id, :quiz_id], :unique => true
    execute <<-SQL
      INSERT INTO questions_quizzes ( quiz_id, question_id )
      SELECT quiz_id, question_id FROM quiz_questions
    SQL
  end
end

