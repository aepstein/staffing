class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      t.references :question, :null => false
      t.references :request
      t.text :content, :null => false

      t.timestamps
    end
    add_index :answers, [ :question_id, :request_id ], :unique => true
  end

  def self.down
    drop_table :answers
  end
end

