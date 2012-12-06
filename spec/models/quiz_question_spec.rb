require 'spec_helper'

describe QuizQuestion do

  let(:quiz_question) { build :quiz_question }

  it "should save with valid attributes" do
    quiz_question.save!
  end

  it "should not save without a quiz" do
    quiz_question.quiz = nil
    quiz_question.save.should be_false
  end

  it "should not save without a question" do
    quiz_question.question = nil
    quiz_question.save.should be_false
  end

  it "should not save with a duplicate question for the same quiz" do
    quiz_question.save!
    duplicate = build(:quiz_question, quiz: quiz_question.quiz,
      question: quiz_question.question)
    duplicate.save.should be_false
  end

  it "should not save without a position" do
    quiz_question.position = nil
    quiz_question.save.should be_false
    quiz_question.position = 0
    quiz_question.save.should be_false
  end

end

